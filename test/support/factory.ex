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

  def card_factory() do
    {literal_value, high_numerical_value, low_numerical_value} = Enum.random(card_values())

    %Card{
      suit: Enum.random(card_suits()),
      literal_value: literal_value,
      high_numerical_value: high_numerical_value,
      low_numerical_value: low_numerical_value
    }
  end

  def card_factory(%{suit: suit, literal_value: literal_value}) do
    {literal_value, low_numerical_value, high_numerical_value} =
      card_values()
      |> Enum.find(fn {literal, _lv, _hv} -> literal == literal_value end)

    %Card{
      suit: suit,
      literal_value: literal_value,
      high_numerical_value: high_numerical_value,
      low_numerical_value: low_numerical_value
    }
  end

  def card_factory(%{literal_value: literal_value}) do
    {literal_value, low_numerical_value, high_numerical_value} =
      card_values()
      |> Enum.find(fn {literal, _lv, _hv} -> literal == literal_value end)

    %Card{
      suit: Enum.random(card_suits()),
      literal_value: literal_value,
      high_numerical_value: high_numerical_value,
      low_numerical_value: low_numerical_value
    }
  end

  def card_factory(attrs) do
    card_factory()
    |> merge_attributes(attrs)
  end

  defp card_suits() do
    [:spade, :club, :heart, :diamond]
  end

  defp card_values() do
    [
      {"2", 2, 2},
      {"3", 3, 3},
      {"4", 4, 4},
      {"5", 5, 5},
      {"6", 6, 6},
      {"7", 7, 7},
      {"8", 8, 8},
      {"9", 9, 9},
      {"10", 10, 10},
      {"J", 11, 11},
      {"Q", 12, 12},
      {"K", 13, 13},
      {"A", 1, 14}
    ]
  end
end
