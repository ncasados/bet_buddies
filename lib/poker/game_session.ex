defmodule Poker.GameSession do
  use GenServer
  alias Poker.Card
  alias Poker.GameState
  alias Phoenix.PubSub
  alias Poker.Player

  @spec bet(pid(), binary(), integer()) :: %GameState{}
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

  @spec join(pid(), binary(), binary()) :: %GameState{}
  def join(pid, player_id, player_name) do
    GenServer.call(pid, {:join, %{"player_id" => player_id, "player_name" => player_name}})
  end

  @impl true
  def handle_info(:update, state) do
    {:noreply, state}
  end

  @impl true
  def handle_call({:bet, player_id, amount} = _msg, _from, %GameState{} = game_state) do
    {amount, _} = if is_binary(amount), do: Integer.parse(amount)
    %{player: betting_player, index: player_index} = find_player(game_state, player_id)

    if betting_player.wallet < amount do
      updated_player = Map.update!(betting_player, :wallet, fn wallet -> wallet - wallet end)

      updated_players =
        List.replace_at(game_state.players, player_index, updated_player)

      game_state =
        Map.update!(game_state, :most_recent_better, fn _ -> updated_player end)
        |> Map.update!(:most_recent_bet, fn _ -> amount end)
        |> Map.update!(:players, fn _ -> updated_players end)
        |> Map.update!(:pot, fn pot -> pot + betting_player.wallet end)
        |> Map.update!(:minimum_bet, fn _ -> amount * 2 end)
        |> Map.update!(:bets, fn last_bets -> [amount | last_bets] end)
        |> Map.update!(:turn_number, fn n ->
          if n + 1 > length(updated_players), do: 1, else: n + 1
        end)

      PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

      {:reply, game_state, game_state}
    else
      updated_player = Map.update!(betting_player, :wallet, fn wallet -> wallet - amount end)

      updated_players =
        List.replace_at(game_state.players, player_index, updated_player)

      game_state =
        Map.update!(game_state, :most_recent_better, fn _ -> updated_player end)
        |> Map.update!(:most_recent_bet, fn _ -> amount end)
        |> Map.update!(:players, fn _ -> updated_players end)
        |> Map.update!(:pot, fn pot -> pot + amount end)
        |> Map.update!(:minimum_bet, fn _ -> amount * 2 end)
        |> Map.update!(:turn_number, fn n ->
          if n + 1 > length(updated_players), do: 1, else: n + 1
        end)

      PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

      {:reply, game_state, game_state}
    end
  end

  def handle_call(:start, _from, %GameState{} = game_state) do
    original_deck = Map.get(game_state, :dealer_deck)
    players = Map.get(game_state, :players)
    shuffled_players = assign_number_to_players_randomly_sort_by_number(players)

    %{new_deck: new_deck, players: ready_players} =
      draw_for_all_players(original_deck, shuffled_players)

    game_state =
      Map.update!(game_state, :game_stage, fn _ -> "ACTIVE" end)
      |> Map.update!(:dealer_deck, fn _ -> new_deck end)
      |> Map.update!(:players, fn _ -> ready_players end)
      |> Map.update!(:turn_number, fn _ -> 1 end)

    PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)

    {:reply, game_state, game_state}
  end

  def handle_call(:read, _from, %GameState{} = game_state) do
    {:reply, game_state, game_state}
  end

  def handle_call(
        {:join, %{"player_id" => player_id, "player_name" => player_name}},
        _from,
        %GameState{} = game_state
      ) do
    case is_player_already_joined?(game_state, player_id) do
      false ->
        game_state = add_player_to_state(game_state, player_id, player_name)
        PubSub.broadcast!(BetBuddies.PubSub, game_state.game_id, :update)
        {:reply, game_state, game_state}

      _ ->
        {:reply, game_state, game_state}
    end
  end

  defp assign_number_to_players_randomly_sort_by_number(players) do
    player_numbers = Enum.shuffle(1..length(players))

    Enum.zip(player_numbers, players)
    |> Enum.map(fn {player_number, player} ->
      Map.update!(player, :number, fn _ -> player_number end)
    end)
    |> Enum.sort(&(&1.number <= &2.number))
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

  @spec is_player_already_joined?(%GameState{}, binary()) :: boolean()
  defp is_player_already_joined?(%GameState{} = game_state, player_id) do
    not is_nil(Enum.find(game_state.players, fn player -> player.player_id == player_id end))
  end

  @spec add_player_to_state(%GameState{}, binary(), binary()) :: %GameState{}
  defp add_player_to_state(%GameState{} = game_state, player_id, player_name) do
    case game_state do
      %GameState{game_stage: "LOBBY"} ->
        Map.update!(game_state, :players, fn player_list ->
          [
            %Player{player_id: player_id, name: player_name, wallet: 1000, hand: []}
            | player_list
          ]
        end)

      _ ->
        game_state
    end
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
