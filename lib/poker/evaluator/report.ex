defmodule Poker.Evaluator.Report do
  @moduledoc """
  Represents a report for the poker hand evaluation. The report includes the high card, the best hand, and the player ID.

  The high card is the highest value card in the hand, which can be used to determine the winner if there are ties.

  The best hand is the highest-ranking poker hand that can be formed from the cards in the hand.
  This could be a straight flush, four of a kind, full house, etc.
  """

  @type t() :: __MODULE__

  defstruct [
    :high_card,
    :best,
    :player_id
  ]
end
