ExUnit.start()

defmodule Poker.EvaluatorTest do
  use ExUnit.Case, async: true

  alias Poker.Card
  alias Poker.Evaluator
  alias Poker.Evaluator.Hands
  alias Poker.Evaluator.Results

  import Poker.Factory

  describe "royal_flush?/1" do
    test "A royal flush is a royal flush" do
      royal_flush =
        [
          build(:card, %{suit: :spade, literal_value: "10"}),
          build(:card, %{suit: :spade, literal_value: "A"}),
          build(:card, %{suit: :spade, literal_value: "J"}),
          build(:card, %{suit: :spade, literal_value: "Q"}),
          build(:card, %{suit: :spade, literal_value: "K"}),
          build(:card, suit: Enum.random([:heart, :diamond, :club])),
          build(:card, suit: Enum.random([:heart, :diamond, :club]))
        ]

      assert %Results{exists?: true} = Evaluator.royal_flush?(royal_flush)
    end

    test "Not a royal flush is not a royal flush" do
      hand =
        [
          build(:card, suit: :club),
          build(:card, suit: :diamond),
          build(:card, suit: :spade),
          build(:card, suit: :heart),
          build(:card, suit: :spade),
          build(:card, suit: :diamond),
          build(:card, suit: :club)
        ]

      assert %Results{exists?: false} = Evaluator.royal_flush?(hand)
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
end
