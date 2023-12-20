defmodule Poker.GameState do
  use Ecto.Schema

  embedded_schema do
    field :game_id, :string
    field :game_started_at, :utc_datetime
    field :password, :string
    field :game_status, :string
    embeds_one :dealer, Poker.Dealer
    field :players, {:array, :map}
  end
end
