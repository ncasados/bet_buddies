defmodule Poker.GameSession do
  use GenServer
  alias Poker.Player

  @impl true
  def handle_call(:read, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:join, %{"player_id" => player_id, "name" => player_name}}, _from, state) do
    state =
      Map.update!(state, "players", fn player_list ->
        [%Player{player_id: player_id, name: player_name, wallet: 1000, hand: []} | player_list]
      end)

    {:reply, state, state}
  end

  def start_link(arguments) do
    GenServer.start_link(__MODULE__, arguments, name: via(arguments.game_id))
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  defp via(game_id) do
    {:via, Registry, {Poker.GameRegistry, game_id}}
  end
end
