defmodule Poker.Evaluator.Results do
  @moduledoc """
  Represents the results of a poker hand evaluation. The results include the type of hand, whether it exists in the hand, the cards that make up the hand, and the index of hand.

  The index is like the value of the hand. For example, a high straight has a higher index than a low straight. A royal flush has the highest index.
  This helps with determining the best hand by a simple sort.
  """

  @type t() :: %__MODULE__{
          type: atom(),
          exists?: boolean(),
          cards: list(Poker.Card.t()),
          index: integer()
        }

  defstruct [
    :type,
    :exists?,
    :cards,
    :index
  ]
end
