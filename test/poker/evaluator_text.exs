ExUnit.start()

defmodule Poker.EvaluatorTest do
  use ExUnit.Case, async: true

  alias Poker.Card
  alias Poker.Evaluator
  alias Poker.Evaluator.Hands
  alias Poker.Evaluator.Results

  describe "royal_flush?/1" do
    test "A royal flush is a royal flush" do
      assert %Results{exists?: true} = Evaluator.royal_flush?(Hands.a_royal_flush())
    end

    test "Not a royal flush is not a royal flush" do
      assert %Results{exists?: false} = Evaluator.royal_flush?(Hands.a_nothing_hand())
    end
  end

  describe "high_card/1" do
    setup do
      %{drawn_cards: hand} =
        Poker.new_shuffled_deck()
        |> Poker.draw(7)

      %{hand: hand}
    end

    test "returns the card of the highest value", %{hand: hand} do
      %Card{high_numerical_value: high_value} = Poker.Evaluator.high_card?(hand)

      assert high_value == Enum.max_by(hand, & &1.high_numerical_value).high_numerical_value
    end
  end

  test "report card of cards" do
    [h1, h2 | dealer_hand] = Poker.Evaluator.Hands.a_nothing_hand()
    player_hand = [h1, h2]

    Evaluator.report("player", player_hand, dealer_hand)
  end
end
