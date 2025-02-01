defmodule Poker.GameStateTest do
  alias Poker.HandLog
  alias Poker.Player
  use ExUnit.Case, async: true

  describe "create_game/2" do
    test "creates a game with the given player" do
      game_id = "some-game-id"

      player = player_factory()

      {:ok, _pid} = Poker.GameSupervisor.create_game(game_id, player)
    end
  end

  defp player_factory do
    %Player{
      player_id: Faker.UUID.v4(),
      name: Faker.Pokemon.name(),
      wallet: 20_000,
      contributed: 0,
      hand: [],
      is_host?: false,
      last_action: %HandLog{},
      last_actions: %HandLog{},
      is_all_in?: false,
      is_big_blind?: false,
      is_small_blind?: false,
      is_under_the_gun?: false,
      turn_number: 0,
      folded?: false,
      funny_collateral: "the house",
      minimum_call: 0
    }
  end
end
