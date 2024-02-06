defmodule Poker.GameState do
  # Put all of the business logic here such as checking the state is correct
  # Stuff such as betting, calling, folding, checking
  # See https://github.com/zblanco/many_ways_to_workflow/blob/master/op_otp/lib/op_otp/

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

  def is_game_active?(%__MODULE__{game_stage: "ACTIVE"}), do: true
  def is_game_active?(%__MODULE__{game_stage: _}), do: false

  def is_game_lobby?(%__MODULE__{game_stage: "LOBBY"}), do: true
  def is_game_lobby?(%__MODULE__{game_stage: _}), do: false

  def enough_players?(%__MODULE__{players: players}) when length(players) >= 2, do: true
  def enough_players?(%__MODULE__{players: players}) when length(players) < 2, do: false
end
