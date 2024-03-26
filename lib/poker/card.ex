defmodule Poker.Card do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :suit, :string
    field :value, :string
  end
end
