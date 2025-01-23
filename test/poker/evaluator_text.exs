ExUnit.start()

defmodule Poker.EvaluatorTest do
  use ExUnit.Case, async: true
  alias Poker.Card
  alias Poker.Evaluator
  alias Poker.Evaluator.Hands

  describe "royal_flush?/1" do
    test "A royal flush is a royal flush" do
      assert true == Evaluator.royal_flush?(Hands.a_royal_flush())
    end

    test "Not a royal flush is not a royal flush" do
      assert false == Evaluator.royal_flush?(Hands.a_nothing_hand())
    end
  end

  test "report card of cards" do
    [h1, h2 | dealer_hand] = a_nothing_hand()
    player_hand = [h1, h2]

    Evaluator.report("player", player_hand, dealer_hand)
  end
end
