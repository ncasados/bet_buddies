defmodule Poker.HandLog do
  @moduledoc """
  Represents a log entry for a poker hand. Each log entry contains the player ID, the action taken, and the value associated with that action.
  """

  @type t :: %__MODULE__{
          player_id: String.t(),
          action: String.t(),
          value: integer()
        }

  defstruct [
    :player_id,
    :action,
    :value
  ]
end
