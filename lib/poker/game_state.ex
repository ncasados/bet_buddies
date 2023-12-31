defmodule Poker.GameState do
  use Ecto.Schema

  embedded_schema do
    field :game_id, :string
    field :game_started_at, :utc_datetime
    field :password, :string
    field :game_stage, :string
    field :dealer_hand, {:array, :map}
    field :dealer_deck, {:array, :map}
    field :pot, :integer
    field :side_pot, :integer
    field :players, {:array, :map}
    field :player_turn, :string
    field :most_recent_bet, :integer
    field :most_recent_better, :string
  end
end
