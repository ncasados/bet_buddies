defmodule Poker.GameSession do
  use GenServer
  alias Poker.Card
  alias Poker.GameState
  alias Phoenix.PubSub
  alias Poker.Player
  alias Poker.HandLog

  @spec all_in(pid(), binary()) :: %GameState{}
  def all_in(pid, player_id) do
    GenServer.call(pid, {:all_in, player_id})
  end

  @spec call(pid(), binary(), binary()) :: %GameState{}
  def call(pid, player_id, amount) do
    GenServer.call(pid, {:call, player_id, amount})
  end

  @spec fold(pid(), binary()) :: %GameState{}
  def fold(pid, player_id) do
    GenServer.call(pid, {:fold, player_id})
  end

  @spec check(pid(), binary()) :: %GameState{}
  def check(pid, player_id) do
    GenServer.call(pid, {:check, player_id})
  end

  @spec bet(pid(), binary(), binary()) :: %GameState{}
  def bet(pid, player_id, amount) do
    GenServer.call(pid, {:bet, player_id, amount})
  end

  @spec start(pid()) :: %GameState{}
  def start(pid) do
    GenServer.call(pid, :start)
  end

  @spec read(pid()) :: %GameState{}
  def read(pid) do
    GenServer.call(pid, :read)
  end

  @spec join(pid(), %Player{}) :: %GameState{}
  def join(pid, player) do
    GenServer.call(pid, {:join, player})
  end

  @impl true
  def handle_info(:update, state) do
    {:noreply, state}
  end

  @impl true
  def handle_call({:all_in, player_id}, _from, %GameState{} = game_state) do
    # If player is all in, and has less than other betters,
    # create a side pot for the richer players.
    %{player: player, index: index} = find_player(game_state, player_id)
    # Get the players current wallet
    wallet = Player.get_wallet(player)
    # Reduce player's wallet to 0
    player = Player.all_in(player)
    # Update Player
    %GameState{} =
      game_state =
      GameState.update_player_by_index(game_state, player, index)
      |> GameState.add_to_main_pot(wallet)
      |> GameState.increment_turn_number()
      |> GameState.add_to_hand_log(%HandLog{
        player_id: player_id,
        action: "All In",
        value: wallet
      })
      |> GameState.set_minimum_call(wallet)
      |> GameState.set_minimum_bet(wallet * 2)

    PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

    {:reply, game_state, game_state}
  end

  def handle_call(
        {:call, player_id, amount},
        _from,
        %GameState{} = game_state
      ) do
    %{player: calling_player, index: player_index} = find_player(game_state, player_id)

    if GameState.is_game_active?(game_state) do
      if GameState.is_players_turn?(game_state, calling_player) do
        {amount, _} = if is_binary(amount), do: Integer.parse(amount)

        updated_player =
          Player.deduct_from_wallet(calling_player, amount)
          |> Player.add_to_bet(amount)

        game_state =
          GameState.update_player_in_players_list(game_state, updated_player)
          |> GameState.add_to_main_pot(amount)
          |> GameState.remove_player_from_queue(updated_player)
          |> GameState.add_to_hand_log(%HandLog{
            player_id: player_id,
            action: "call",
            value: amount
          })

        PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

        {:reply, game_state, game_state}
      else
        {:reply, :not_players_turn, game_state}
      end
    else
      {:reply, :game_not_active, game_state}
    end
  end

  def handle_call({:fold, player_id}, _from, %GameState{} = game_state) do
    if GameState.is_game_active?(game_state) do
      %{player: player, index: player_index} = find_player(game_state, player_id)

      updated_player = Player.set_folded(player, true)

      game_state =
        GameState.update_player_in_players_list(game_state, updated_player)
        |> GameState.remove_player_from_queue(updated_player)
        |> GameState.add_to_hand_log(%HandLog{player_id: player_id, action: "fold", value: 0})

      PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

      {:reply, game_state, game_state}
    else
      {:reply, :game_not_active, game_state}
    end
  end

  def handle_call({:check, player_id}, _from, %GameState{} = game_state) do
    if GameState.is_game_active?(game_state) do
      %{player: player, index: player_index} = find_player(game_state, player_id)

      game_state =
        GameState.remove_player_from_queue(game_state, player)
        |> GameState.add_to_hand_log(%HandLog{player_id: player_id, value: 0, action: "check"})

      PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

      {:reply, game_state, game_state}
    else
      {:reply, :game_not_active, game_state}
    end
  end

  def handle_call({:bet, player_id, amount} = _msg, _from, %GameState{} = game_state) do
    %{player: betting_player, index: player_index} = find_player(game_state, player_id)

    if GameState.is_game_active?(game_state) do
      if GameState.is_players_turn?(game_state, betting_player) do
        {amount, _} = if is_binary(amount), do: Integer.parse(amount)

        updated_player =
          Player.deduct_from_wallet(betting_player, amount)
          |> Player.add_to_bet(amount)

        game_state =
          GameState.update_player_in_players_list(game_state, updated_player)
          |> GameState.set_player_queue(GameState.get_players(game_state))
          |> GameState.remove_player_from_queue(updated_player)
          |> GameState.add_to_main_pot(amount)
          |> GameState.set_minimum_bet(amount * 2)
          |> GameState.set_most_recent_max_bet(GameState.get_max_bet_from_players(game_state))
          |> GameState.increment_turn_number()
          |> GameState.add_to_hand_log(%HandLog{
            player_id: player_id,
            action: "bet",
            value: amount
          })

        PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

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
        |> Player.add_to_bet(big_blind)

      small_blind_player =
        Player.set_small_blind(small_blind_player, true)
        |> Player.deduct_from_wallet(small_blind)
        |> Player.add_to_bet(small_blind)

      players = [big_blind_player, small_blind_player | the_rest]

      player_queue = [small_blind_player | the_rest]

      game_state =
        game_state
        |> GameState.set_player_queue(player_queue)
        |> GameState.set_players(players)
        |> GameState.set_gamestate_to_active()
        |> GameState.set_minimum_bet(big_blind * 2)
        |> GameState.set_most_recent_max_bet(get_max_bet_from_players(player_queue))
        |> GameState.add_to_main_pot(big_blind + small_blind)
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
    case GameState.is_player_already_joined?(game_state, player) do
      false ->
        game_state = GameState.add_player_to_state(game_state, player)
        PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)
        {:reply, game_state, game_state}

      _ ->
        {:reply, game_state, game_state}
    end
  end

  def get_max_bet_from_players(players) do
    [first_player | _tail] =
      Enum.sort_by(players, fn %Player{contributed: contributed} -> contributed end, :desc)

    Map.get(first_player, :contributed)
  end

  defp assign_big_blind_and_little_blind_to_last_two_players(players) do
    # assing big blind and little blind to players.
    # big_blind_player = Map.update!(player_0, :is_big_blind?, fn _ -> true end)
    # small_blind_player = Map.update!(player_1, :is_small_blind?, fn _ -> true end)
    [player1 | [player2 | the_rest]] = Enum.reverse(players)

    big_blind_bet = 800
    small_blind_bet = 400

    player1 =
      Map.update!(player1, :is_big_blind?, fn _ -> true end)
      |> Map.update!(:wallet, fn wallet -> wallet - 800 end)
      |> Map.update!(:contributed, fn contributed -> contributed + big_blind_bet end)

    player2 =
      Map.update!(player2, :is_small_blind?, fn _ -> true end)
      |> Map.update!(:wallet, fn wallet -> wallet - 400 end)
      |> Map.update!(:contributed, fn contributed -> contributed + small_blind_bet end)

    [player1 | [player2 | the_rest]]
  end

  defp assign_number_to_players(players) do
    player_numbers = Enum.shuffle(1..length(players))

    Enum.zip(player_numbers, players)
    |> Enum.map(fn {player_number, player} ->
      Map.update!(player, :turn_number, fn _ -> player_number end)
    end)
    |> Enum.sort(&(&1.turn_number <= &2.turn_number))
  end

  @spec find_player(%GameState{}, binary()) :: %{player: %Player{}, index: integer()}
  defp find_player(%GameState{} = game_state, player_id) do
    %{
      player: Enum.find(game_state.players, fn player -> player.player_id == player_id end),
      index: Enum.find_index(game_state.players, fn player -> player.player_id == player_id end)
    }
  end

  @spec draw_for_all_players([%Card{}], [%Player{}]) :: %{
          new_deck: [%Card{}],
          players: [%Player{}]
        }
  defp draw_for_all_players(deck, players) do
    Enum.reduce(players, %{new_deck: deck, players: []}, fn player, acc ->
      %{new_deck: new_deck, drawn_cards: drawn_cards} = Poker.draw(acc.new_deck, 2)

      player =
        Map.update!(player, :hand, fn prior_hand ->
          Enum.reduce(drawn_cards, prior_hand, fn new_card, prior_hand ->
            [new_card | prior_hand]
          end)
        end)

      %{new_deck: new_deck, players: [player | acc.players]}
    end)
  end

  # GenServer startup

  def start_link(%GameState{} = game_state) do
    GenServer.start_link(__MODULE__, game_state, name: via(game_state.game_id))
  end

  @impl true
  def init(%GameState{} = game_state) do
    PubSub.subscribe(BetBuddies.PubSub, game_state.game_id)
    {:ok, game_state}
  end

  defp via(game_id) do
    {:via, Registry, {Poker.GameRegistry, game_id}}
  end
end
