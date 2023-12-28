defmodule Poker.GameSession do
  use GenServer
  alias Poker.GameState
  alias Phoenix.PubSub
  alias Poker.Player

  @spec read(pid()) :: %GameState{}
  def read(pid) do
    GenServer.call(pid, :read)
  end

  @spec join(pid(), binary(), binary()) :: %GameState{}
  def join(pid, player_id, player_name) do
    GenServer.call(pid, {:join, %{"player_id" => player_id, "player_name" => player_name}})
  end

  @impl true
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

  defp is_player_already_joined?(%GameState{} = game_state, player_id) do
    not is_nil(Enum.find(game_state.players, fn player -> player.player_id == player_id end))
  end

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
