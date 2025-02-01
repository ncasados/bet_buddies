defmodule Poker.HandLog do
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
