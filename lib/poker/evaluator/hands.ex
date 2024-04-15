defmodule Poker.Evaluator.Hands do
  alias Poker.Card

  def a_nothing_hand() do
    Poker.new_shuffled_deck()
    |> Enum.reduce([], fn
      %Card{suit: "spade", literal_value: "2"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "4"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "6"} = card, acc ->
        [card] ++ acc

      %Card{suit: "heart", literal_value: "8"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "10"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "Q"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "A"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end

  def a_one_pair() do
    Poker.new_shuffled_deck()
    |> Enum.reduce([], fn
      %Card{suit: "spade", literal_value: "2"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "2"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "4"} = card, acc ->
        [card] ++ acc

      %Card{suit: "heart", literal_value: "6"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "8"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "10"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "Q"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end

  def a_two_pair() do
    Poker.new_shuffled_deck()
    |> Enum.reduce([], fn
      %Card{suit: "spade", literal_value: "2"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "2"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "3"} = card, acc ->
        [card] ++ acc

      %Card{suit: "heart", literal_value: "3"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "4"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "4"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "8"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end

  def a_three_of_a_kind() do
    Poker.new_shuffled_deck()
    |> Enum.reduce([], fn
      %Card{suit: "spade", literal_value: "2"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "2"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "2"} = card, acc ->
        [card] ++ acc

      %Card{suit: "heart", literal_value: "3"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "3"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "3"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "4"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end

  def a_straight() do
    Poker.new_shuffled_deck()
    |> Enum.reduce([], fn
      %Card{suit: "spade", literal_value: "10"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "9"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "8"} = card, acc ->
        [card] ++ acc

      %Card{suit: "heart", literal_value: "7"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "6"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "2"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "3"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end

  def a_flush() do
    suits = ["spade", "diamond", "club", "heart"]
    flush_suit = Enum.random(suits)

    Poker.new_shuffled_deck()
    |> Enum.reduce([], fn
      %Card{suit: ^flush_suit, literal_value: "A"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "J"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "10"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "7"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "8"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "2"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "3"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end

  def a_full_house() do
    Poker.new_shuffled_deck()
    |> Enum.reduce([], fn
      %Card{suit: "spade", literal_value: "A"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "A"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "A"} = card, acc ->
        [card] ++ acc

      %Card{suit: "heart", literal_value: "7"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "7"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "2"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "3"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end

  def a_four_of_a_kind() do
    Poker.new_shuffled_deck()
    |> Enum.reduce([], fn
      %Card{suit: "spade", literal_value: "Q"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "Q"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "Q"} = card, acc ->
        [card] ++ acc

      %Card{suit: "heart", literal_value: "Q"} = card, acc ->
        [card] ++ acc

      %Card{suit: "spade", literal_value: "6"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "A"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "A"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end

  def a_straight_flush() do
    suits = ["spade", "diamond", "club", "heart"]
    flush_suit = Enum.random(suits)

    Poker.new_shuffled_deck()
    |> Enum.reduce([], fn
      %Card{suit: ^flush_suit, literal_value: "10"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "9"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "8"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "7"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "6"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "5"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "4"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end

  def a_royal_flush() do
    suits = ["spade", "diamond", "club", "heart"]
    flush_suit = Enum.random(suits)

    Poker.new_shuffled_deck()
    |> Enum.reduce([], fn
      %Card{suit: ^flush_suit, literal_value: "A"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "K"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "Q"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "J"} = card, acc ->
        [card] ++ acc

      %Card{suit: ^flush_suit, literal_value: "10"} = card, acc ->
        [card] ++ acc

      %Card{suit: "club", literal_value: "A"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "A"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end
end
