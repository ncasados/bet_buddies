defmodule Poker do
  alias Ecto.UUID

  def new_game_id() do
    UUID.generate()
  end

  def get_game_state(pid) do
    Poker.GameSession.read(pid)
  end

  def join_game(game_id, player_id, player_name) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
    Poker.GameSession.join(pid, player_id, player_name)
  end

  def create_game(game_id, player_id, player_name) do
    Poker.GameSupervisor.create_game(game_id, player_id, player_name)
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
    %Poker.Draw{drawn_cards: drawn_cards, new_deck: deck -- drawn_cards}
  end
end
