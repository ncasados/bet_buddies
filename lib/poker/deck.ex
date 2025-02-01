defmodule Poker.Deck do
  alias Poker.Card

  @type t :: list(Card.t())

  @spec new() :: list(Card.t())
  def new() do
    suits = ["spade", "heart", "club", "diamond"]

    values = [
      {"2", 2, 2},
      {"3", 3, 3},
      {"4", 4, 4},
      {"5", 5, 5},
      {"6", 6, 6},
      {"7", 7, 7},
      {"8", 8, 8},
      {"9", 9, 9},
      {"10", 10, 10},
      {"J", 11, 11},
      {"Q", 12, 12},
      {"K", 13, 13},
      {"A", 1, 14}
    ]

    for suit <- suits, {literal_value, low_value, high_value} <- values do
      %Poker.Card{
        suit: suit,
        literal_value: literal_value,
        low_numerical_value: low_value,
        high_numerical_value: high_value
      }
    end
  end

  @spec shuffle(deck :: list(Card.t())) :: list(Card.t())
  def shuffle(deck) do
    Enum.shuffle(deck)
  end
end
