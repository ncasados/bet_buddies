defmodule Poker.Evaluator do
  alias Poker.Card

  @spec royal_flush?(list(Card)) :: :royal_flush_exists | :no_royal_flush_exists
  def royal_flush?(list_of_cards) do
    card_suit_group =
      Enum.group_by(list_of_cards, fn %Card{} = card -> card.suit end)
      |> Enum.filter(fn {_suit, cards} -> Enum.count(cards) >= 5 end)

    case card_suit_group do
      [] ->
        :no_royal_flush_exists

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
          :royal_flush_exists
        else
          :no_royal_flush_exists
        end
    end
  end

  def straight_flush?(list_of_cards) do
    card_suit_group =
      Enum.group_by(list_of_cards, fn %Card{} = card -> card.suit end)
      |> Enum.filter(fn {_suit, cards} -> Enum.count(cards) >= 5 end)

    case card_suit_group do
      [] ->
        :no_straight_flush_exists

      [{_suit, cards}] ->
        with {true, _cards} <-
               Enum.sort_by(cards, fn %Card{} = card -> card.low_numerical_value end)
               |> Enum.chunk_every(5, 1, :discard)
               |> IO.inspect()
               |> Enum.map(&five_in_sequence?(&1))
               |> IO.inspect()
               |> Enum.reject(fn {key, _cards} -> key == false end)
               |> List.last() do
          :straight_flush_exists
        else
          nil -> :no_straight_flush_exists
        end
    end
  end

  def five_in_sequence?(list), do: check_sequence(list, nil, [])
  def check_sequence([], card_ah, acc), do: {true, [card_ah | acc]}
  def check_sequence([%Card{} = card_h | t], nil, acc), do: check_sequence(t, card_h, acc)

  def check_sequence([%Card{} = card_h | t], %Card{} = card_ah, acc)
      when card_ah.low_numerical_value == card_h.low_numerical_value - 1,
      do: check_sequence(t, card_h, [card_ah | acc])

  def check_sequence(_, _, acc), do: {false, acc}

  def a_straight_flush() do
    Poker.new_shuffled_deck()
    |> Enum.reduce([], fn
      %Card{suit: "spade", literal_value: "10"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "9"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "8"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "7"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "6"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "5"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "4"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end

  def a_real_royal_flush() do
    Poker.new_shuffled_deck()
    |> Enum.reduce([], fn
      %Card{suit: "spade", literal_value: "A"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "K"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "Q"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "J"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "10"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "A"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "A"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end
end
