defmodule Poker.Factory do
  @moduledoc """
  Provides helper for building structs and schemas
  """

  use ExMachina

  alias Poker.Card
  alias Poker.GameState
  alias Poker.HandLog
  alias Poker.Player

  def active_game_state_factory do
    %GameState{
      game_id: Faker.UUID.v4(),
      game_started_at: Faker.DateTime.forward(1),
      password: "some-password",
      game_stage: :ACTIVE,
      dealer_hand: [],
      dealer_deck: [],
      main_pot: 20_000,
      side_pots: [],
      players: [],
      player_queue: [],
      turn_number: 1,
      next_call: 0,
      minimum_bet: 0,
      big_blind: 0,
      small_blind: 0,
      hand_log: [],
      flop_dealt?: false,
      turn_dealt?: false,
      river_dealt?: false,
      player_hand_reports: [],
      round_winner: %Player{},
      round_number: 1
    }
  end

  def player_factory do
    %Player{
      contributed: 0,
      folded?: false,
      funny_collateral: "the house",
      hand: [],
      is_all_in?: false,
      is_big_blind?: false,
      is_host?: false,
      is_small_blind?: false,
      is_under_the_gun?: false,
      last_action: nil,
      last_actions: [],
      minimum_call: 0,
      name: Faker.Person.En.name(),
      player_id: Faker.UUID.v4(),
      turn_number: 1,
      wallet: 0
    }
  end

  def hand_log_factory do
    %HandLog{
      player_id: Faker.UUID.v4(),
      action: :check,
      value: 0
    }
  end

  def card_factory do
    %Card{
      suit: :spade,
      literal_value: "A",
      high_numerical_value: 14,
      low_numerical_value: 1
    }
  end
end
