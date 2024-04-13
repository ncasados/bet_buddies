ExUnit.start()

defmodule Poker.EvaluatorTest do
  use ExUnit.Case, async: true
  alias Poker.Card
  alias Poker.Evaluator

  test "A royal flush is a royal flush" do
    assert true == Evaluator.royal_flush?(a_royal_flush())
  end

  test "Not a royal flush is not a royal flush" do
    assert false == Evaluator.royal_flush?(a_nothing_hand())
  end

  test "report card of cards" do
    [h1, h2 | dealer_hand] = a_nothing_hand()
    player_hand = [h1, h2]

    Evaluator.report("player", player_hand, dealer_hand)
    |> IO.inspect()
  end

  defp a_nothing_hand() do
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

  defp a_three_of_a_kind() do
    suits = ["spade", "diamond", "club", "heart"]
    flush_suit = Enum.random(suits)

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

  defp a_straight() do
    suits = ["spade", "diamond", "club", "heart"]
    flush_suit = Enum.random(suits)

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

  defp a_flush() do
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

  defp a_full_house() do
    suits = ["spade", "diamond", "club", "heart"]
    flush_suit = Enum.random(suits)

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

  defp a_four_of_a_kind() do
    suits = ["spade", "diamond", "club", "heart"]
    flush_suit = Enum.random(suits)

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

  defp a_straight_flush() do
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

      %Card{suit: "club", literal_value: "A"} = card, acc ->
        [card] ++ acc

      %Card{suit: "diamond", literal_value: "A"} = card, acc ->
        [card] ++ acc

      _card, acc ->
        acc
    end)
  end

  defp a_royal_flush() do
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
