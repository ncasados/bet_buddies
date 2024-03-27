defmodule Poker.Card do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :suit, :string
    field :literal_value, :string
    field :high_numerical_value, :integer
    field :low_numerical_value, :integer
  end
end
