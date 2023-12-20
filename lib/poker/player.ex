defmodule Poker.Player do
  use Ecto.Schema

  embedded_schema do
    field :player_id, :string
    field :name, :string
    field :wallet, :integer
    field :hand, {:array, :map}
  end
end
