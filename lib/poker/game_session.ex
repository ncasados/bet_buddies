defmodule Poker.GameSession do
  use GenServer
  alias Poker.Card
  alias Poker.GameState
  alias Phoenix.PubSub
  alias Poker.Player
  alias Poker.HandLog

  @spec all_in(pid(), binary()) :: %GameState{}
  def all_in(pid, player_id) do
    # Set up all in action
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
    _wallet = Player.get_wallet(player)
    # Reduce player's wallet to 0
    player = Player.all_in(player)
    # Check if there are at least 3 players in the hand after the all in.
    GameState.create_sidepot?(game_state)
    # Update Player
    %GameState{} = game_state = GameState.update_player_by_index(game_state, player, index)
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
          Map.update!(calling_player, :wallet, fn wallet ->
            wallet - amount
          end)
          |> Map.update!(:bet, fn bet -> bet + amount end)

        updated_players =
          List.replace_at(game_state.players, player_index, updated_player)

        game_state =
          GameState.update_players(game_state, updated_players)
          |> GameState.add_to_main_pot(amount)
          |> GameState.increment_turn_number()
          |> GameState.add_to_hand_log(%HandLog{player_id: player_id, action: "call", value: amount})

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
        GameState.update_player_by_index(game_state, updated_player, player_index)
        |> GameState.increment_turn_number()
        |> GameState.add_to_hand_log(%HandLog{player_id: player_id, action: "fold", value: 0})

      PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

      {:reply, game_state, game_state}
    else
      {:reply, :game_not_active, game_state}
    end
  end

  def handle_call({:check, player_id}, _from, %GameState{} = game_state) do
    if GameState.is_game_active?(game_state) do
      game_state =
        GameState.increment_turn_number(game_state)
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

        if Player.has_enough_money?(betting_player, amount) do
          updated_player =
            Player.deduct_from_wallet(betting_player, amount)
            |> Player.add_to_bet(amount)

          updated_players =
            GameState.update_player_by_index(game_state, updated_player, player_index)
            |> Map.get(:players)

          game_state =
            GameState.update_players(game_state, updated_players)
            |> GameState.add_to_main_pot(amount)
            |> GameState.set_minimum_bet(amount * 2)
            |> GameState.set_most_recent_max_bet(get_max_bet_from_players(updated_players))
            |> GameState.increment_turn_number()
            |> GameState.add_to_hand_log(%HandLog{player_id: player_id, action: "bet", value: amount})

          PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

          {:reply, game_state, game_state}
        else
          updated_player =
            Map.update!(betting_player, :wallet, fn wallet -> wallet - wallet end)
            |> Map.update!(:bet, fn _ -> amount end)

          updated_players =
            List.replace_at(game_state.players, player_index, updated_player)

          game_state =
            GameState.update_players(game_state, updated_players)
            |> GameState.add_to_main_pot(betting_player.wallet)
            |> GameState.set_minimum_bet(amount * 2)
            |> GameState.set_most_recent_max_bet(get_max_bet_from_players(updated_players))
            |> GameState.increment_turn_number()
            |> GameState.add_to_hand_log(%HandLog{player_id: player_id, action: "bet", value: amount})

          PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

          {:reply, game_state, game_state}
        end
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
      original_deck = Poker.new_shuffled_deck()
      players = GameState.get_players(game_state)

      blinded_and_labeled_players =
        players
        |> assign_number_to_players()
        |> assign_big_blind_and_little_blind_to_last_two_players()

      %{new_deck: new_deck, players: ready_players} =
        draw_for_all_players(original_deck, blinded_and_labeled_players)

      game_state =
        GameState.set_gamestate_to_active(game_state)
        |> GameState.update_dealer_deck(new_deck)
        |> GameState.update_players(ready_players)
        |> GameState.set_turn_number(1)
        |> GameState.set_minimum_bet(big_blind * 2)
        |> GameState.set_most_recent_max_bet(get_max_bet_from_players(ready_players))
        |> GameState.add_to_main_pot(big_blind + small_blind)

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
    [first_player | _tail] = Enum.sort_by(players, fn %Player{bet: bet} -> bet end, :desc)
    Map.get(first_player, :bet)
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
      |> Map.update!(:bet, fn bet -> bet + big_blind_bet end)

    player2 =
      Map.update!(player2, :is_small_blind?, fn _ -> true end)
      |> Map.update!(:wallet, fn wallet -> wallet - 400 end)
      |> Map.update!(:bet, fn bet -> bet + small_blind_bet end)

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
