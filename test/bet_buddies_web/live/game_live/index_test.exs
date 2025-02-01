defmodule BetBuddiesWeb.GameLive.IndexTest do
  use BetBuddiesWeb.ConnCase

  alias Poker.Player

  import Phoenix.LiveViewTest

  describe "lobby 1p game" do
    setup %{conn: conn} do
      game_id = Faker.UUID.v4()
      player = %Player{player_id: Faker.UUID.v4(), name: "Goku"}
      conn = put_req_cookie(conn, "player_id", player.player_id)
      Poker.create_game(game_id, player)

      %{conn: conn, game_id: game_id}
    end

    test "GET /game/:game_id lobby game stage", %{conn: conn, game_id: game_id} do
      assert {:ok, _view, html} = live(conn, ~p"/game/#{game_id}")

      assert html =~ "Start Game"
    end
  end

  describe "lobby 2p game" do
    setup %{conn: conn} do
      game_id = Faker.UUID.v4()
      player = %Player{player_id: Faker.UUID.v4(), name: "Goku"}
      player_2 = %Player{player_id: Faker.UUID.v4(), name: "Vegeta"}
      conn = put_req_cookie(conn, "player_id", player.player_id)

      Poker.create_game(game_id, player)
      Poker.join_game(game_id, player_2)

      %{conn: conn, game_id: game_id}
    end

    test "GET /game/:game_id move to active game stage", %{conn: conn, game_id: game_id} do
      assert {:ok, view, _html} =
               live(conn, ~p"/game/#{game_id}")

      assert view
             |> element(~s{[name="start-game-form"]})
             |> put_submitter(~s{button[name="start-game-button"]})
             |> render_submit()

      assert {:ok, _view, html} =
               live(conn, ~p"/game/#{game_id}")

      refute html =~ "Start Game"
    end
  end

  describe "lobby 3p game" do
    setup %{conn: conn} do
      game_id = Faker.UUID.v4()

      player_1 = %Player{player_id: Faker.UUID.v4(), name: "Goku"}
      player_2 = %Player{player_id: Faker.UUID.v4(), name: "Vegeta"}
      player_3 = %Player{player_id: Faker.UUID.v4(), name: "Piccolo"}

      conn = put_req_cookie(conn, "player_id", player_1.player_id)

      Poker.create_game(game_id, player_1)
      Poker.join_game(game_id, player_2)
      Poker.join_game(game_id, player_3)

      %{conn: conn, game_id: game_id}
    end

    test "GET /game/:game_id move to active game stage", %{conn: conn, game_id: game_id} do
      conn = get(conn, ~p"/game/#{game_id}")

      assert "LOBBY" == conn.assigns.game_state.game_stage

      assert {:ok, view, _html} =
               live(conn, ~p"/game/#{game_id}")

      assert view
             |> element("form", "Start Game")
             |> put_submitter(~s{button[name="start-game-button"]})
             |> render_submit()

      conn = get(conn, ~p"/game/#{game_id}")

      assert "ACTIVE" == conn.assigns.game_state.game_stage

      assert {:ok, _view, html} =
               live(conn, ~p"/game/#{game_id}")

      refute html =~ "Start Game"
      assert html =~ "Goku"
      assert html =~ "Vegeta"
      assert html =~ "Piccolo"
    end
  end

  describe "active 3p game" do
    setup %{conn: _conn} do
      game_id = Faker.UUID.v4()

      player_1 = %Player{player_id: Faker.UUID.v4(), name: "Goku"}
      player_2 = %Player{player_id: Faker.UUID.v4(), name: "Vegeta"}
      player_3 = %Player{player_id: Faker.UUID.v4(), name: "Piccolo"}

      Poker.create_game(game_id, player_1)
      Poker.join_game(game_id, player_2)
      Poker.join_game(game_id, player_3)
      Poker.start_game(game_id)

      player_connections =
        Enum.reduce([player_1, player_2, player_3], %{}, fn player, acc ->
          Map.merge(acc, %{
            player.player_id =>
              build_conn()
              |> put_req_cookie("player_id", player.player_id)
          })
        end)

      game_state = Poker.get_game_state(game_id)

      %{
        player_connections: player_connections,
        game_id: game_id,
        game_state: game_state
      }
    end

    test "GET /game/:game_id calling", %{
      player_connections: player_connections,
      game_id: game_id,
      game_state: game_state
    } do
      [under_the_gun_player] = game_state.player_queue

      conn = Map.get(player_connections, under_the_gun_player.player_id)

      assert conn = get(conn, ~p"/game/#{game_id}")

      assert {:ok, _view, html} =
               live(conn, ~p"/game/#{game_id}")

      assert html =~ "Call"
    end
  end
end
