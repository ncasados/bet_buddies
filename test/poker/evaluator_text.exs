ExUnit.start()

defmodule Poker.EvaluatorTest do
  use ExUnit.Case, async: true
  alias Poker.Card
  alias Poker.Evaluator

  test "A royal flush is a royal flush" do
    assert :royal_flush_exists = Evaluator.royal_flush?(a_real_royal_flush())
  end

  test "Not a royal flush is not a royal flush" do
    assert :no_royal_flush_exists = Evaluator.royal_flush?(not_a_royal_flush())
  end

  defp not_a_royal_flush() do
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

  defp a_real_royal_flush() do
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
