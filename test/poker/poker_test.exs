alias Erl2exVendored.Pipeline.ExFunc
ExUnit.start()

defmodule Poker.PokerTest do
  use ExUnit.Case, async: true

  test "Two shuffled decks are not the same" do
    assert Poker.new_shuffled_deck() != Poker.new_shuffled_deck()
  end

  test "Draw two cards" do
    %{drawn_cards: drawn_cards, new_deck: new_deck} =
      Poker.new_shuffled_deck()
      |> Poker.draw(2)

    assert length(drawn_cards) == 2
    assert length(new_deck) == 50
  end
end
