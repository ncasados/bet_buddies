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
    field :turn_number, :integer
    field :minimum_bet, :integer, default: 0
    field :most_recent_max_bet, :integer, default: 0
    field :big_blind, :integer, default: 800
    field :small_blind, :integer, default: 400
  end
end
