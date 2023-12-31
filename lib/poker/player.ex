defmodule Poker.Player do
  use Ecto.Schema

  embedded_schema do
    field :player_id, :string
    field :name, :string
    field :wallet, :integer
    field :hand, {:array, :map}, default: []
    field :is_host?, :boolean, default: false
    field :is_big_blind?, :boolean, default: false
    field :is_small_blind?, :boolean, default: false
    field :is_under_the_gun?, :boolean, default: false
  end
end
