defmodule Poker.GameSession do
  @moduledoc """
  Defines functions that manage a poker game session.
  """

  use GenServer, restart: :transient

  alias Phoenix.PubSub
  alias Poker.GameState
  alias Poker.HandLog
  alias Poker.Player

  @spec all_in(pid(), binary()) :: GameState.t()
  def all_in(pid, player_id) do
    GenServer.call(pid, {:all_in, player_id})
  end

  @spec call(pid(), binary(), binary()) :: GameState.t()
  def call(pid, player_id, amount) do
    GenServer.call(pid, {:call, player_id, amount})
  end

  @spec fold(pid(), binary()) :: GameState.t()
  def fold(pid, player_id) do
    GenServer.call(pid, {:fold, player_id})
  end

  @spec check(pid(), binary()) :: GameState.t()
  def check(pid, player_id) do
    GenServer.call(pid, {:check, player_id})
  end

  @spec bet(pid(), binary(), binary()) :: GameState.t()
  def bet(pid, player_id, amount) do
    GenServer.call(pid, {:bet, player_id, amount})
  end

  @spec start(pid()) :: GameState.t()
  def start(pid) do
    GenServer.call(pid, :start)
  end

  @spec read(pid()) :: GameState.t()
  def read(pid) do
    GenServer.call(pid, :read)
  end

  @spec join(pid(), Player.t()) :: GameState.t()
  def join(pid, player) do
    GenServer.call(pid, {:join, player})
  end

  def next_round(pid) do
    GenServer.call(pid, :next_round)
  end

  @impl true
  def handle_info(:update, state) do
    {:noreply, state}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_call({:all_in, player_id}, _from, %GameState{} = game_state) do
    %{player: player} = find_player(game_state, player_id)

    if GameState.game_active?(game_state) do
      if GameState.players_turn?(game_state, player) do
        # If player is all in, and has less than other betters,
        # create a side pot for the richer players.
        %{player: player} = find_player(game_state, player_id)
        # Get the players current wallet
        wallet = Player.get_wallet(player)
        # Reduce player's wallet to 0
        player = Player.all_in(player)

        game_state = GameState.update_player_in_players_list(game_state, player)

        # Update Player
        %GameState{} =
          game_state =
          game_state
          |> GameState.remove_player_from_queue(player)
          |> GameState.set_minimum_calls_on_players()
          |> GameState.add_to_main_pot(wallet)
          |> GameState.set_minimum_bet(wallet * 2)
          |> GameState.add_to_hand_log(%HandLog{
            player_id: player_id,
            action: :all_in,
            value: wallet
          })
          |> GameState.move_to_next_stage()
          |> GameState.increment_turn_number()

        PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

        kill_self_after_time()

        {:reply, game_state, game_state}
      else
        {:reply, :not_players_turn, game_state}
      end
    else
      {:reply, :game_not_active, game_state}
    end
  end

  def handle_call(
        {:call, player_id, amount},
        _from,
        %GameState{} = game_state
      ) do
    %{player: calling_player, index: _player_index} = find_player(game_state, player_id)

    if GameState.game_active?(game_state) do
      if GameState.players_turn?(game_state, calling_player) do
        {amount, _} = if is_binary(amount), do: Integer.parse(amount)

        updated_player =
          Player.deduct_from_wallet(calling_player, amount)
          |> Player.add_to_contribution(amount)

        game_state =
          GameState.update_player_in_players_list(game_state, updated_player)
          |> GameState.set_minimum_calls_on_players()

        game_state =
          game_state
          |> GameState.add_to_main_pot(amount)
          |> GameState.remove_player_from_queue(updated_player)
          |> GameState.increment_turn_number()
          |> GameState.add_to_hand_log(%HandLog{
            player_id: player_id,
            action: :call,
            value: amount
          })
          |> GameState.move_to_next_stage()

        PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

        kill_self_after_time()

        {:reply, game_state, game_state}
      else
        {:reply, :not_players_turn, game_state}
      end
    else
      {:reply, :game_not_active, game_state}
    end
  end

  def handle_call({:fold, player_id}, _from, %GameState{} = game_state) do
    if GameState.game_active?(game_state) do
      %{player: player, index: _player_index} = find_player(game_state, player_id)

      updated_player = Player.set_folded(player, true)

      game_state =
        GameState.update_player_in_players_list(game_state, updated_player)
        |> GameState.remove_player_from_queue(updated_player)
        |> GameState.add_to_hand_log(%HandLog{player_id: player_id, action: :fold, value: 0})
        |> GameState.move_to_next_stage()

      PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

      kill_self_after_time()

      {:reply, game_state, game_state}
    else
      {:reply, :game_not_active, game_state}
    end
  end

  def handle_call({:check, player_id}, _from, %GameState{} = game_state) do
    if GameState.game_active?(game_state) do
      %{player: player} = find_player(game_state, player_id)

      game_state =
        GameState.remove_player_from_queue(game_state, player)
        |> GameState.add_to_hand_log(%HandLog{player_id: player_id, value: 0, action: :check})
        |> GameState.move_to_next_stage()

      PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

      kill_self_after_time()

      {:reply, game_state, game_state}
    else
      {:reply, :game_not_active, game_state}
    end
  end

  def handle_call({:bet, player_id, amount} = _msg, _from, %GameState{} = game_state) do
    %{player: betting_player} = find_player(game_state, player_id)

    if GameState.game_active?(game_state) do
      if GameState.players_turn?(game_state, betting_player) do
        {amount, _} = if is_binary(amount), do: Integer.parse(amount)

        updated_player =
          Player.deduct_from_wallet(betting_player, amount)
          |> Player.add_to_contribution(amount)

        game_state =
          GameState.update_player_in_players_list(game_state, updated_player)
          |> GameState.set_minimum_calls_on_players()

        game_state =
          game_state
          |> GameState.set_player_queue(GameState.get_players(game_state))
          |> GameState.remove_player_from_queue(updated_player)
          |> GameState.add_to_main_pot(amount)
          |> GameState.set_minimum_bet(amount * 2)
          |> GameState.increment_turn_number()
          |> GameState.add_to_hand_log(%HandLog{
            player_id: player_id,
            action: :bet,
            value: amount
          })
          |> dbg()

        PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

        kill_self_after_time()

        {:reply, game_state, game_state}
      else
        {:reply, :not_players_turn, game_state}
      end
    else
      {:reply, :game_not_active, game_state}
    end
  end

  def handle_call(
        :start,
        _from,
        %GameState{big_blind: big_blind, small_blind: small_blind} = game_state
      ) do
    if GameState.enough_players?(game_state) do
      game_state =
        GameState.set_dealer_deck(game_state, Poker.new_shuffled_deck())
        |> GameState.shuffle_players()
        |> GameState.draw_for_all_players()

      players =
        GameState.get_players(game_state)

      [big_blind_player, small_blind_player | the_rest] = Enum.reverse(players)

      big_blind_player =
        Player.set_big_blind(big_blind_player, true)
        |> Player.deduct_from_wallet(big_blind)
        |> Player.add_to_contribution(big_blind)

      small_blind_player =
        Player.set_small_blind(small_blind_player, true)
        |> Player.deduct_from_wallet(small_blind)
        |> Player.add_to_contribution(small_blind)

      players = [big_blind_player, small_blind_player | the_rest]

      game_state =
        game_state
        |> GameState.set_players(players)
        |> GameState.set_minimum_calls_on_players()

      player_queue =
        case length(game_state.players) do
          length when length == 2 ->
            [_big_blind | player_queue] = game_state.players
            player_queue

          length when length > 2 ->
            [_big_blind, _little_blind | player_queue] = game_state.players
            player_queue
        end

      game_state =
        game_state
        |> GameState.set_player_queue(player_queue)
        |> GameState.set_gamestate_to_active()
        |> GameState.set_minimum_bet(big_blind * 2)
        |> GameState.add_to_main_pot(big_blind + small_blind)
        |> GameState.set_next_call()
        |> GameState.set_turn_number(1)

      PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

      {:reply, game_state, game_state}
    else
      {:reply, :not_enough_players, game_state}
    end
  end

  def handle_call(:read, _from, %GameState{} = game_state) do
    {:reply, game_state, game_state}
  end

  def handle_call(
        {:join, %Player{} = player},
        _from,
        %GameState{} = game_state
      ) do
    case GameState.player_already_joined?(game_state, player) do
      false ->
        game_state = GameState.add_player_to_state(game_state, player)
        PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)
        {:reply, game_state, game_state}

      _ ->
        {:reply, game_state, game_state}
    end
  end

  def handle_call(:next_round, _from, state) do
    GameState.increment_round_number(state)
    {:reply, state, state}
  end

  def get_max_contribution_from_players(players) do
    [first_player | _tail] =
      Enum.sort_by(players, fn %Player{contributed: contributed} -> contributed end, :desc)

    Map.get(first_player, :contributed)
  end

  @spec find_player(GameState.t(), binary()) :: %{player: Player.t(), index: integer()}
  defp find_player(%GameState{} = game_state, player_id) do
    %{
      player: Enum.find(game_state.players, fn player -> player.player_id == player_id end),
      index: Enum.find_index(game_state.players, fn player -> player.player_id == player_id end)
    }
  end

  defp kill_self_after_time() do
    Process.send_after(self(), :stop, 3_600_000)
  end

  # GenServer startup

  def start_link(%GameState{} = game_state) do
    GenServer.start_link(__MODULE__, game_state, name: via(game_state.game_id))
  end

  @impl true
  def init(%GameState{} = game_state) do
    PubSub.subscribe(BetBuddies.PubSub, game_state.game_id)
    kill_self_after_time()
    {:ok, game_state}
  end

  defp via(game_id) do
    {:via, Registry, {Poker.GameRegistry, game_id}}
  end
end
