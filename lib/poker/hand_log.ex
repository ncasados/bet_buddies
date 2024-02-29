defmodule Poker.HandLog do
  use Ecto.Schema

  embedded_schema do
    field :player_id, :string
    field :action, :string
    field :value, :integer
  end
end
