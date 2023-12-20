defmodule Poker.Dealer do
  use Ecto.Schema

  embedded_schema do
    field :hand, {:array, :map}
    field :deck, {:array, :map}
    field :pot, :integer
    field :side_pot, :integer
  end
end
