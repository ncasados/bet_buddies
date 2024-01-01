defmodule Poker.GameState do
  use Ecto.Schema

  embedded_schema do
    field :game_id, :string
    field :game_started_at, :utc_datetime
    field :password, :string
    field :game_stage, :string
    embeds_many :dealer_hand, Poker.Card
    embeds_many :dealer_deck, Poker.Card
    field :pot, :integer
    field :side_pot, :integer
    embeds_many :players, Poker.Player
    field :player_turn, :string
    field :most_recent_bet, :integer
    embeds_one :most_recent_better, Poker.Player
    field :next_minimum_bet, :integer
  end
end
