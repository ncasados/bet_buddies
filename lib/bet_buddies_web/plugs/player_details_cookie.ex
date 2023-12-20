defmodule BetBuddiesWeb.Plugs.PlayerDetailsCookie do
  import Plug.Conn

  def init(_), do: []

  def call(conn, _opts) do
    new_uuid = Ecto.UUID.generate()
    player_id_cookie = conn.cookies["player_id"]

    case player_id_cookie do
      nil ->
        set_player_id_cookie_and_session(conn, new_uuid)

      _ ->
        set_player_id_cookie_and_session(conn, player_id_cookie)
    end
  end

  def set_player_id_cookie_and_session(conn, player_id) do
    put_resp_cookie(conn, "player_id", player_id)
    |> put_session("player_id", player_id)
    |> assign(:player_id, player_id)
  end
end
