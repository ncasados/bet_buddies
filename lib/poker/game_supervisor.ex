defmodule Poker.GameSupervisor do
  @moduledoc """
  A dynamic supervisor for starting poker games. Each poker game is managed by a GameSession process.
  """

  use DynamicSupervisor

  alias Poker.GameSession
  alias Poker.GameState
  alias Poker.Player

  def create_game(game_id, %Player{} = player) do
    player = Player.set_host(player)

    DynamicSupervisor.start_child(
      __MODULE__,
      {GameSession,
       %GameState{
         game_id: game_id,
         game_started_at: DateTime.utc_now(),
         password: "",
         game_stage: "LOBBY",
         players: [player]
       }}
    )
  end

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
