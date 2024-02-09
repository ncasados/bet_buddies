ExUnit.start()

defmodule Poker.PokerTest do
  use ExUnit.Case, async: true

  test "player cannot call while game is not started" do
    assert {:ok, pid} = Poker.create_game("test_game_id", "test_player_id", "test_player")
    assert :game_not_active = Poker.bet("test_game_id", "test_player_id", 200)
    assert :ok = DynamicSupervisor.terminate_child(Poker.GameSupervisor, pid)
  end

  test "player cannot bet while game is not started" do
    assert {:ok, pid} = Poker.create_game("test_game_id", "test_player_id", "test_player")
    assert :game_not_active = Poker.bet("test_game_id", "test_player_id", 20000)
    assert :ok = DynamicSupervisor.terminate_child(Poker.GameSupervisor, pid)
  end

  test "player starts with 20,000" do
    assert {:ok, pid} = Poker.create_game("test_game_id", "test_player_id", "test_player")
    assert %Poker.GameState{players: [%Poker.Player{wallet: wallet}]} = Poker.GameSession.read(pid)
    assert 20000 = wallet
    assert :ok = DynamicSupervisor.terminate_child(Poker.GameSupervisor, pid)
  end

  test "player is added to game when game is created" do
    assert {:ok, pid} = Poker.create_game("test_game_id", "test_player_id", "test_player")
    assert %Poker.GameState{players: players} = Poker.GameSession.read(pid)
    assert 1 = length(players)
    assert :ok = DynamicSupervisor.terminate_child(Poker.GameSupervisor, pid)
  end

  test "game can be created" do
    assert {:ok, pid} = Poker.create_game("test_game_id", "test_player_id", "test_player")
    assert :ok = DynamicSupervisor.terminate_child(Poker.GameSupervisor, pid)
  end

  test "Two shuffled decks are not the same" do
    assert Poker.new_shuffled_deck() != Poker.new_shuffled_deck()
  end

  test "Draw two cards" do
    %{drawn_cards: drawn_cards, new_deck: new_deck} =
      Poker.new_shuffled_deck()
      |> Poker.draw(2)

    assert length(drawn_cards) == 2
    assert length(new_deck) == 50
  end
end
