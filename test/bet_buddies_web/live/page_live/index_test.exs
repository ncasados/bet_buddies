defmodule BetBuddiesWeb.PageLive.IndexTest do
  use BetBuddiesWeb.ConnCase

  alias Poker.Player

  import Phoenix.LiveViewTest

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Play Texas Hold'em With Friends"
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

    assert game_lobby_html =~ "Waiting for players"
  end

  test "Join a game", %{conn: conn} do
    game_id = Faker.UUID.v4()

    assert {:ok, _pid} =
             Poker.create_game(game_id, %Player{name: "Goku", player_id: Faker.UUID.v4()})

    conn = put_req_cookie(conn, "player_id", Faker.UUID.v4())

    {:ok, view, _html} = live(conn, ~p"/")

    assert {:ok, _view, html} =
             view
             |> form("#join-game-form", %{
               "joining-player-name-field" => "Vegeta",
               "joining-game-id-field" => game_id
             })
             |> render_submit()
             |> follow_redirect(conn)

    assert html =~ "Waiting for host to start game"
  end
end
