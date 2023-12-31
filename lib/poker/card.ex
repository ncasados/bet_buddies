defmodule Poker.Card do
  use Ecto.Schema

  embedded_schema do
    field :suit, :string
    field :value, :string
  end
end
