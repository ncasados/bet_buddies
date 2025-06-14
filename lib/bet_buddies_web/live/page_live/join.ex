defmodule BetBuddiesWeb.PageLive.Join do
  use BetBuddiesWeb, :html
  use Phoenix.Component
  use Phoenix.LiveView

  alias Poker.Player

  def mount(params, %{"player_id" => player_id} = _session, socket) do
    case Map.get(params, "game_id") do
      nil ->
        socket = assign(socket, :error_log, "Game ID not provided")

        {:ok, socket}

      game_id ->
        socket =
          assign(socket,
            game_id: game_id,
            player_id: player_id
          )

        {:ok, socket}
    end
  end

  def handle_event(
        "join-game",
        %{"join-game-button" => game_id, "joining-player-name-field" => player_name} =
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
    <%= if Map.get(assigns, :error_log) do %>
      <div class="text-red-500 font-bold text-center mb-4">
        <%= @error_log %>
      </div>
    <% else %>
      <div class="min-h-screen bg-gradient-to-br from-blue-50 to-purple-50 p-8">
        <div class="flex flex-col items-center space-y-8">
          <p class="font-bold text-4xl text-gray-800 bg-clip-text text-transparent bg-gradient-to-r from-blue-600 to-purple-600">
            Play Texas Hold'em With Friends
          </p>
          <div class="relative h-48 w-64 mb-8">
            <div class="absolute top-0 left-0 w-40 h-56 bg-white rounded-xl shadow-lg transform -rotate-12 transition-all hover:-rotate-6 hover:translate-y-[-8px] border-2 border-white/50">
              <div class="p-2">
                <div class="text-red-600 font-bold text-xl">A</div>
                <div class="text-red-600 text-4xl text-center mt-4">♥</div>
              </div>
            </div>
            <div class="absolute top-0 left-8 w-40 h-56 bg-white rounded-xl shadow-lg transform rotate-12 transition-all hover:rotate-6 hover:translate-y-[-8px] border-2 border-white/50">
              <div class="p-2">
                <div class="text-black font-bold text-xl">K</div>
                <div class="text-black text-[68px] text-center mt-4">♠</div>
              </div>
            </div>
          </div>
          <div class="flex flex-row justify-center gap-8 flex-wrap">
            <form
              phx-submit="join-game"
              id="join-game-form"
              name="join-game-form"
              class="flex flex-col justify-center w-80 p-6 rounded-2xl backdrop-blur-lg bg-white/30 shadow-lg border border-white/50"
            >
              <h1 class="font-bold text-xl text-center mb-4 text-gray-700">Join a game</h1>
              <input
                type="text"
                name="joining-player-name-field"
                id="joining-player-name-field"
                placeholder="player name"
                class="text-center p-3 mb-4 rounded-xl bg-white/50 border border-white/70 focus:outline-none focus:ring-2 focus:ring-purple-400/50 transition-all"
              />
              <button
                type="submit"
                name="join-game-button"
                id="join-game-button"
                class="bg-gradient-to-r from-purple-500 to-blue-500 p-4 rounded-xl text-white font-medium hover:from-purple-600 hover:to-blue-600 transition-all shadow-md hover:shadow-lg"
                value={@game_id}
              >
                Join Game
              </button>
            </form>
          </div>
        </div>
      </div>
    <% end %>
    """
  end
end
