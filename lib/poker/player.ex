defmodule Poker.Player do
  use Ecto.Schema

  embedded_schema do
    field :player_id, :string
    field :name, :string
    field :wallet, :integer
    field :hand, {:array, :map}, default: []
    field :is_host?, :boolean, default: false
  end
end
