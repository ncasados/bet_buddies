defmodule Poker.Evaluator do
  alias Poker.Card
  @spec royal_flush?(list(Card)) :: :royal_flush_exists
  def royal_flush?(list_of_cards) do
    card_suit_group = Enum.group_by(list_of_cards, fn %Card{} = card -> card.suit end)
    any_five_same_suit = Map.new(Enum.filter(card_suit_group, fn {suit, cards} -> Enum.count(cards) >= 5 end))
    if any_five_same_suit == %{} do
      :no_fucking_royal_flush
    else
      # Let's check if A, K, Q, J, 10
    end
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
