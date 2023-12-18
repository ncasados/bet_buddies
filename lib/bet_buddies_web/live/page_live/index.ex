defmodule BetBuddiesWeb.PageLive.Index do
  use Phoenix.LiveView
  use Phoenix.Component

  def mount(_params, session, socket) do
    IO.inspect(session, label: "SESSION")
    {:ok, assign(socket, :game_id, Poker.new_game_id())}
  end

  def handle_event("create_game", %{"create_game_button" => game_id}, socket) do
    {:noreply, push_navigate(socket, to: "/game/#{game_id}")}
  end

  def handle_event("join_game", %{"joining_game_id_field" => game_id, "joining_player_name_field" => player_name}, socket) do
    {:noreply, push_navigate(socket, to: "/game/#{game_id}?n=#{player_name}")}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-row justify-center">
      <form phx-submit="create_game" id="create_game_form" name="create_game_form" class="flex flex-col justify-center max-w-xs m-2 justify-between">
        <input type="text" name="player_name_field" id="player_name_field" placeholder="player name" class="text-center"/>
        <button
          type="submit"
          name="create_game_button"
          id="create_game_button"
          class="bg-purple-500 p-4 rounded-3xl text-white"
          value={@game_id}
        >
          Create Game
        </button>
      </form>
      <form phx-submit="join_game" id="join_game_form" name="join_game_form" class="flex flex-col justify-center max-w-xs m-2 space-y-2 justify-between">
        <input type="text" name="joining_player_name_field" id="joining_player_name_field" placeholder="player name" class="text-center"/>
        <input type="text" name="joining_game_id_field" id="joining_game_id_field" placeholder="game id" class="text-center"/>
        <button
          type="submit"
          name="join_game_button"
          id="join_game_button"
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
