defmodule Poker.Evaluator.Results do
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
