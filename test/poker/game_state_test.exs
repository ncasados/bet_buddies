defmodule Poker.GameStateTest do
  use ExUnit.Case, async: true

  alias Poker.GameState

  import Poker.Factory

  describe "create_game/2" do
    test "creates a game with the given player" do
      game_id = "some-game-id"

      player = build(:player)

      {:ok, _pid} = Poker.GameSupervisor.create_game(game_id, player)
    end
  end

  describe "increment_round_number/1" do
    test "increments the round number by one" do
      game_state = build(:active_game_state)

      GameState.increment_round_number(game_state)
    end
  end
end
