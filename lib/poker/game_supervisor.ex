defmodule Poker.GameSupervisor do
  use DynamicSupervisor
  alias Poker.Player
  alias Poker.GameState
  alias Poker.GameSession

  def create_game(game_id, player_id, player_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {GameSession,
       %GameState{
         game_id: game_id,
         game_started_at: DateTime.utc_now(),
         password: "",
         game_stage: "LOBBY",
         dealer_hand: [],
         dealer_deck: Poker.new_shuffled_deck(),
         pot: 0,
         side_pot: 0,
         players: [
           %Player{
             player_id: player_id,
             name: player_name,
             hand: [],
             wallet: 1000,
             is_host?: true,
             number: 1
           }
         ]
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
