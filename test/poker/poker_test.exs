ExUnit.start()

defmodule Poker.PokerTest do
  use ExUnit.Case, async: true

  alias Ecto.UUID
  alias Poker.GameState
  alias Poker.Player

  describe "create_game/2" do
    test "successfully create a game" do
      game_id = UUID.generate()

      player = %Player{
        player_id: UUID.generate(),
        name: "test_player_a"
      }

      assert {:ok, _pid} = Poker.create_game(game_id, player)
    end
  end

  describe "join_game/2" do
    setup do
      game_id = UUID.generate()

      player = %Player{
        player_id: UUID.generate(),
        name: "test_player_a"
      }

      Poker.create_game(game_id, player)

      %{game_id: game_id}
    end

    test "player successfully joins a game", %{game_id: game_id} do
      input_player = %Player{
        player_id: UUID.generate(),
        name: "test_player_b"
      }

      game_state = Poker.join_game(game_id, input_player)

      player_to_test = GameState.find_player(game_state, input_player.player_id)

      assert input_player.player_id == player_to_test.player_id
    end
  end

  describe "start_game/1" do
    setup do
      game_id = UUID.generate()

      player_a = %Player{
        player_id: UUID.generate(),
        name: "test_player_a"
      }

      player_b = %Player{
        player_id: UUID.generate(),
        name: "test_player_b"
      }

      assert {:ok, _pid} = Poker.create_game(game_id, player_a)

      Poker.join_game(game_id, player_b)

      %{game_id: game_id}
    end

    test "successfully start a game", %{game_id: game_id} do
      game_state = Poker.start_game(game_id)

      # Game should be active
      assert %GameState{game_stage: "ACTIVE", next_call: next_call, turn_number: 1} = game_state

      # Next call should not be 0
      assert next_call != 0

      # Big blind should not be in queue
      big_blind_player =
        Map.get(game_state, :players)
        |> Enum.find(fn %Player{is_big_blind?: is_big_blind} -> is_big_blind end)

      assert nil ==
               Map.get(game_state, :player_queue)
               |> Enum.find(fn %Player{player_id: player_id} ->
                 player_id == big_blind_player.player_id
               end)
    end
  end

  describe "all_in/2" do
    setup do
      players = [
        %Player{
          player_id: UUID.generate(),
          name: "test_player_a"
        },
        %Player{
          player_id: UUID.generate(),
          name: "test_player_b"
        }
      ]

      [player_a | players_to_add] = players

      game_id = UUID.generate()

      Poker.create_game(game_id, player_a)

      players_to_add
      |> Enum.each(&Poker.join_game(game_id, &1))

      game_state = Poker.start_game(game_id)

      %{
        started_game: game_state
      }
    end

    test "player successfully all ins", %{
      started_game: %GameState{
        game_id: game_id,
        player_queue: [%Player{player_id: all_in_player_id} | _tail]
      }
    } do
      game_state = Poker.all_in(game_id, all_in_player_id)

      # All In Player should not be in queue
      assert nil == GameState.find_player_in_queue(game_state, all_in_player_id)

      # Turn should increment
      assert %GameState{turn_number: 2} = game_state

      # All In Player should have empty wallet
      assert %Player{wallet: 0} = GameState.find_player(game_state, all_in_player_id)

      # All in Player should have contributed wallet amount
      assert %Player{contributed: 20_000} = GameState.find_player(game_state, all_in_player_id)

      assert %GameState{} = game_state
    end
  end

  describe "call/3" do
    setup do
      players = [
        %Player{
          player_id: UUID.generate(),
          name: "test_player_a",
          wallet: 2000
        },
        %Player{
          player_id: UUID.generate(),
          name: "test_player_b",
          wallet: 2000
        },
        %Player{
          player_id: UUID.generate(),
          name: "test_player_c",
          wallet: 2000
        },
        %Player{
          player_id: UUID.generate(),
          name: "test_player_d",
          wallet: 2000
        }
      ]

      [player_a | players_to_add] = players

      game_id = UUID.generate()
      Poker.create_game(game_id, player_a)

      players_to_add
      |> Enum.each(&Poker.join_game(game_id, &1))

      game_state = Poker.start_game(game_id)

      %{
        started_game: game_state
      }
    end

    test "successfully call", %{started_game: %GameState{game_id: game_id, players: players}} do
      [player_a | _tail] = players

      Poker.call(game_id, player_a.player_id, 200)
    end
  end
end
