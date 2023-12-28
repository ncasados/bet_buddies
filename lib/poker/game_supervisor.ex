defmodule Poker.GameSupervisor do
  use DynamicSupervisor
  alias Poker.Player

  def create_game(game_id, player_id, player_name) do
    deck = Poker.new_shuffled_deck()

    %Poker.Draw{drawn_cards: drawn_cards, new_deck: new_deck} = Poker.draw(deck, 2)

    DynamicSupervisor.start_child(
      Poker.GameSupervisor,
      {Poker.GameSession,
       %Poker.GameState{
         game_id: game_id,
         game_started_at: DateTime.utc_now(),
         password: "",
         game_stage: "LOBBY",
         dealer: %Poker.Dealer{
           hand: [],
           deck: new_deck,
           pot: 0,
           side_pot: 0
         },
         players: [
           %Player{
             player_id: player_id,
             name: player_name,
             hand: drawn_cards,
             wallet: 1000
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
