defmodule Poker.Evaluator do
  alias Poker.Card
  alias Poker.Evaluator.Hands
  alias Poker.Evaluator.Results
  alias Poker.Evaluator.Report

  def report(player_id, hand, dealer_hand) do
    high_card = high_card?(hand)
    list_of_cards = hand ++ dealer_hand

    best =
      [
        royal_flush?(list_of_cards),
        straight_flush?(list_of_cards),
        four_of_a_kind?(list_of_cards),
        full_house?(list_of_cards),
        flush?(list_of_cards),
        straight?(list_of_cards),
        three_of_a_kind?(list_of_cards),
        two_pair?(list_of_cards),
        one_pair?(list_of_cards)
      ]

    # |> get_best()

    %Report{high_card: high_card, best: best, player_id: player_id}
  end

  def report() do
    [h1, h2 | dealer_hand] = Hands.a_nothing_hand()
    hand = [h1, h2]
    high_card = high_card?(hand)
    list_of_cards = hand ++ dealer_hand

    best =
      [
        royal_flush?(list_of_cards),
        straight_flush?(list_of_cards),
        four_of_a_kind?(list_of_cards),
        full_house?(list_of_cards),
        flush?(list_of_cards),
        straight?(list_of_cards),
        three_of_a_kind?(list_of_cards),
        two_pair?(list_of_cards),
        one_pair?(list_of_cards)
      ]

    %Report{high_card: high_card, best: best, player_id: "player_id"}
  end

  def get_best(report) do
    Enum.find(report, fn
      {:royal_flush, value, _cards} -> value
      {:straight_flush, value, _cards} -> value
      {:four_of_a_kind, value, _cards} -> value
      {:full_house, value, _cards} -> value
      {:flush, value, _cards} -> value
      {:straight, value, _cards} -> value
      {:three_of_a_kind, value, _cards} -> value
      {:two_pair, value, _cards} -> value
      {:one_pair, value, _cards} -> value
    end)
  end

  @spec royal_flush?(list(Card)) :: %Results{}
  def royal_flush?(list_of_cards) do
    royal_flush_exists = true
    no_royal_flush_exists = false

    card_suit_group =
      Enum.group_by(list_of_cards, fn %Card{} = card -> card.suit end)
      |> Enum.filter(fn {_suit, cards} -> Enum.count(cards) >= 5 end)

    case card_suit_group do
      [] ->
        %Results{type: :royal_flush, exists?: no_royal_flush_exists, cards: []}

      [{_suit, cards}] ->
        card_count =
          Enum.sort_by(cards, fn %Card{} = card -> card.high_numerical_value end)
          |> Enum.reduce([], fn
            %Card{high_numerical_value: 10} = card, acc ->
              [card] ++ acc

            %Card{high_numerical_value: 11} = card, acc ->
              [card] ++ acc

            %Card{high_numerical_value: 12} = card, acc ->
              [card] ++ acc

            %Card{high_numerical_value: 13} = card, acc ->
              [card] ++ acc

            %Card{high_numerical_value: 14} = card, acc ->
              [card] ++ acc

            _card, acc ->
              acc
          end)
          |> Enum.count()

        if card_count == 5 do
          %Results{type: :royal_flush, exists?: royal_flush_exists, cards: cards}
        else
          %Results{type: :royal_flush, exists?: no_royal_flush_exists, cards: []}
        end
    end
  end

  def straight_flush?(list_of_cards) do
    straight_flush_exists = true
    no_straight_flush_exists = false

    card_suit_group =
      Enum.group_by(list_of_cards, fn %Card{} = card -> card.suit end)
      |> Enum.filter(fn {_suit, cards} -> Enum.count(cards) >= 5 end)

    case card_suit_group do
      [] ->
        %Results{type: :straight_flush, exists?: no_straight_flush_exists, cards: []}

      [{_suit, cards}] ->
        with {true, cards} <-
               Enum.sort_by(cards, fn %Card{} = card -> card.low_numerical_value end)
               |> Enum.chunk_every(5, 1, :discard)
               |> Enum.map(&five_in_sequence?(&1))
               |> Enum.reject(fn {key, _cards} -> key == false end)
               |> List.last() do
          %Results{type: :straight_flush, exists?: straight_flush_exists, cards: cards}
        else
          nil ->
            %Results{type: :straight_flush, exists?: no_straight_flush_exists, cards: []}
        end
    end
  end

  def four_of_a_kind?(list_of_cards) do
    four_of_a_kind_exists = true
    no_four_of_a_kind = false

    card_values_group =
      Enum.group_by(list_of_cards, fn %Card{} = card -> card.literal_value end)
      |> Enum.filter(fn {_literal_values, cards} -> Enum.count(cards) == 4 end)

    case card_values_group do
      [] ->
        %Results{type: :four_of_a_kind, exists?: no_four_of_a_kind, cards: []}

      [{_suit, cards}] ->
        %Results{type: :four_of_a_kind, exists?: four_of_a_kind_exists, cards: cards}
    end
  end

  def full_house?(list_of_cards) do
    full_house_exists = true
    no_full_house = false

    with [group1, group2] <-
           Enum.group_by(list_of_cards, fn %Card{} = card -> card.high_numerical_value end)
           |> Enum.filter(fn
             {_literal_values, cards} when length(cards) == 3 -> true
             {_literal_values, cards} when length(cards) == 2 -> true
             {_literal_values, _cards} -> false
           end)
           |> Map.new()
           |> Map.values() do
      case {length(group1), length(group2)} do
        {2, 3} ->
          %Results{type: :full_house, exists?: full_house_exists, cards: group1 ++ group2}

        _ ->
          %Results{type: :full_house, exists?: no_full_house, cards: []}
      end
    else
      _ -> %Results{type: :full_house, exists?: no_full_house, cards: []}
    end
  end

  def flush?(list_of_cards) do
    flush_exists = true
    no_flush_exists = false

    with [{_suit, cards}] <-
           Enum.sort_by(list_of_cards, fn %Card{high_numerical_value: value} -> value end)
           |> Enum.group_by(fn %Card{} = card -> card.suit end)
           |> Enum.filter(fn {_suit, cards} -> Enum.count(cards) >= 5 end) do
      %Results{type: :flush, exists?: flush_exists, cards: cards}
    else
      _ -> %Results{type: :flush, exists?: no_flush_exists, cards: []}
    end
  end

  def straight?(list_of_cards) do
    straight_exists = true
    no_straight_exists = false

    with {true, cards} <-
           Enum.sort_by(list_of_cards, fn %Card{} = card -> card.low_numerical_value end)
           |> Enum.chunk_every(5, 1, :discard)
           |> Enum.map(&five_in_sequence?(&1))
           |> Enum.reject(fn {key, _cards} -> key == false end)
           |> List.last() do
      %Results{type: :straight, exists?: straight_exists, cards: cards}
    else
      nil ->
        %Results{
          type: :three_of_a_kind,
          exists?: no_straight_exists,
          cards: []
        }
    end
  end

  def three_of_a_kind?(list_of_cards) do
    three_of_a_kind_exists = true
    no_three_of_a_kind_exists = false

    card_values_group =
      Enum.group_by(list_of_cards, fn %Card{} = card -> card.high_numerical_value end)
      |> Enum.filter(fn {_literal_values, cards} -> Enum.count(cards) == 3 end)
      |> Map.new()
      |> Map.values()
      |> Enum.sort_by(fn [%Card{high_numerical_value: value} | _cards] -> value end)
      |> List.last()

    case card_values_group do
      nil ->
        %Results{type: :three_of_a_kind, exists?: no_three_of_a_kind_exists, cards: []}

      _ ->
        %Results{
          type: :three_of_a_kind,
          exists?: three_of_a_kind_exists,
          cards: card_values_group
        }
    end
  end

  def two_pair?(list_of_cards) do
    two_pair_exists = true
    no_two_pair_exists = false

    card_values_group =
      Enum.group_by(list_of_cards, fn %Card{} = card -> card.high_numerical_value end)
      |> Enum.filter(fn {_literal_values, cards} -> Enum.count(cards) == 2 end)
      |> Map.new()
      |> Map.values()
      |> Enum.sort_by(fn [%Card{high_numerical_value: value} | _cards] -> value end, :desc)

    with [pair1, pair2 | _the_rest] <- card_values_group do
      highest_pair = [pair1, pair2]
      %Results{type: :two_pair, exists?: two_pair_exists, cards: highest_pair}
    else
      _ -> %Results{type: :two_pair, exists?: no_two_pair_exists, cards: []}
    end
  end

  def one_pair?(list_of_cards) do
    pair_exists = true
    no_pair_exists = false

    card_values_group =
      Enum.group_by(list_of_cards, fn %Card{} = card -> card.high_numerical_value end)
      |> Enum.filter(fn {_literal_values, cards} -> Enum.count(cards) == 2 end)
      |> Map.new()
      |> Map.values()
      |> Enum.sort_by(fn [%Card{high_numerical_value: value} | _cards] -> value end)
      |> List.last()

    case card_values_group do
      nil ->
        %Results{type: :one_pair, exists?: no_pair_exists, cards: []}

      _ ->
        %Results{type: :one_pair, exists?: pair_exists, cards: card_values_group}
    end
  end

  def high_card?(list_of_cards) do
    Enum.sort_by(list_of_cards, fn %Card{} = card -> card.high_numerical_value end)
    |> List.last()
  end

  defp five_in_sequence?(list), do: check_sequence(list, nil, [])
  defp check_sequence([], card_ah, acc), do: {true, [card_ah | acc]}
  defp check_sequence([%Card{} = card_h | t], nil, acc), do: check_sequence(t, card_h, acc)

  defp check_sequence([%Card{} = card_h | t], %Card{} = card_ah, acc)
       when card_ah.low_numerical_value == card_h.low_numerical_value - 1,
       do: check_sequence(t, card_h, [card_ah | acc])

  defp check_sequence(_, _, acc), do: {false, acc}
end
