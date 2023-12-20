defmodule Poker do
  alias Ecto.UUID
  alias Poker.Player

  def new_game_id() do
    UUID.generate()
  end

  def create_game(game_id, player_id, player_name) do
    deck = new_shuffled_deck()

    DynamicSupervisor.start_child(
      Poker.GameSupervisor,
      {Poker.GameSession,
       %Poker.GameState{
         game_id: game_id,
         game_started_at: DateTime.utc_now(),
         password: "",
         game_status: "ACTIVE",
         dealer: %Poker.Dealer{
           hand: [],
           deck: deck,
           pot: 0,
           side_pot: 0
         },
         players: [
           %Player{
             player_id: player_id,
             name: player_name,
             hand: [],
             wallet: 1000
           }
         ]
       }}
    )
  end

  def new_shuffled_deck() do
    suits = ["spade", "heart", "club", "diamond"]
    values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

    for suit <- suits, value <- values do
      %{
        "suit" => suit,
        "value" => value
      }
    end
    |> Enum.shuffle()
  end

  def draw(deck, draw_count) do
    drawn_cards = Enum.take(deck, draw_count)
    %{"drawn_cards" => drawn_cards, "new_deck" => deck -- drawn_cards}
  end
end
