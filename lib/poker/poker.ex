defmodule Poker do
  alias Poker.Card
  alias Ecto.UUID

  def bet(game_id, player_id, amount) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
    Poker.GameSession.bet(pid, player_id, amount)
  end

  def new_game_id() do
    UUID.generate()
  end

  def start_game(game_id) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
    Poker.GameSession.start(pid)
  end

  def get_game_state(game_id) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
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
      %Poker.Card{
        suit: suit,
        value: value
      }
    end
    |> Enum.shuffle()
  end

  @spec draw([%Card{}], integer()) :: %{drawn_cards: [%Card{}], new_deck: [%Card{}]}
  def draw(deck, draw_count) do
    drawn_cards = Enum.take(deck, draw_count)
    %{drawn_cards: drawn_cards, new_deck: deck -- drawn_cards}
  end
end
