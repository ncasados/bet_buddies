defmodule Poker.Card do
  @moduledoc """
  Represents a poker card. Each card has a suit and a literal value, as well as high and low numerical values.
  """

  @type t :: %__MODULE__{
          suit: String.t(),
          literal_value: String.t(),
          high_numerical_value: integer(),
          low_numerical_value: integer()
        }

  defstruct [
    :suit,
    :literal_value,
    :high_numerical_value,
    :low_numerical_value
  ]
end
