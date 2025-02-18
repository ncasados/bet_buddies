defmodule BetBuddiesWeb.PageLive.Index do
  alias Poker.Player
  use Phoenix.LiveView
  use Phoenix.Component

  def mount(_params, %{"player_id" => player_id} = _session, socket) do
    socket =
      assign(socket, :game_id, Poker.new_game_id())
      |> assign(:player_id, player_id)

    {:ok, socket}
  end

  def handle_event(
        "create-game",
        %{"create-game-button" => game_id, "player-name-field" => player_name} = _params,
        %{assigns: assigns} = socket
      ) do
    player = %Player{player_id: assigns.player_id, name: player_name}
    Poker.create_game(game_id, player)
    {:noreply, push_navigate(socket, to: "/game/#{game_id}")}
  end

  def handle_event(
        "join-game",
        %{"joining-game-id-field" => game_id, "joining-player-name-field" => player_name} =
          _params,
        %{assigns: assigns} = socket
      ) do
    player = %Player{player_id: assigns.player_id, name: player_name}
    Poker.join_game(game_id, player)
    socket = assign(socket, :game_id, game_id)
    {:noreply, push_navigate(socket, to: "/game/#{game_id}")}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-row justify-center">
      <form
        phx-submit="create-game"
        id="create-game-form"
        name="create-game-form"
        class="flex flex-col justify-center max-w-xs m-2 justify-between"
      >
        <h1 class="font-bold text-xl text-center">Create a game</h1>
        <input
          type="text"
          name="player-name-field"
          id="player-name-field"
          placeholder="player name"
          class="text-center"
        />
        <button
          type="submit"
          name="create-game-button"
          id="create-game-button"
          class="bg-purple-500 p-4 rounded-3xl text-white"
          value={@game_id}
        >
          Create Game
        </button>
      </form>
      <form
        phx-submit="join-game"
        id="join-game-form"
        name="join-game-form"
        class="flex flex-col justify-center max-w-xs m-2 space-y-2 justify-between"
      >
        <h1 class="font-bold text-xl text-center">Join a game</h1>
        <input
          type="text"
          name="joining-player-name-field"
          id="joining-player-name-field"
          placeholder="player name"
          class="text-center"
        />
        <input
          type="text"
          name="joining-game-id-field"
          id="joining-game-id-field"
          placeholder="game id"
          class="text-center"
        />
        <button
          type="submit"
          name="join-game-button"
          id="join-game-button"
          class="bg-purple-500 p-4 rounded-3xl text-white"
          value={@game_id}
        >
          Join Game
        </button>
      </form>
    </div>
    """
  end
end
