defmodule BetBuddiesWeb.PageLive.IndexTest do
  use BetBuddiesWeb.ConnCase

  import Phoenix.LiveViewTest

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Create Game"
    assert html_response(conn, 200) =~ "Join Game"
  end

  test "create a game", %{conn: conn} do
    conn = put_req_cookie(conn, "player_id", Faker.UUID.v4())

    {:ok, view, _html} = live(conn, ~p"/")

    assert {:ok, _view, game_lobby_html} =
             view
             |> render_submit("create-game", %{
               "create-game-button" => Faker.UUID.v4(),
               "player-name-field" => "Goku"
             })
             |> follow_redirect(conn)

    assert game_lobby_html =~ "Start Game"
  end
end
