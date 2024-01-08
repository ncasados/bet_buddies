defmodule Poker do
  alias Poker.GameState
  alias Poker.Card
  alias Ecto.UUID

  @spec bet(binary(), binary(), integer()) :: %GameState{}
  def bet(game_id, player_id, amount) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
    Poker.GameSession.bet(pid, player_id, amount)
  end

  @spec new_game_id() :: binary()
  def new_game_id() do
    UUID.generate()
  end

  @spec start_game(binary()) :: %GameState{}
  def start_game(game_id) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
    Poker.GameSession.start(pid)
  end

  @spec get_game_state(binary()) :: %GameState{}
  def get_game_state(game_id) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
    Poker.GameSession.read(pid)
  end

  @spec join_game(binary(), binary(), binary()) :: %GameState{}
  def join_game(game_id, player_id, player_name) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
    Poker.GameSession.join(pid, player_id, player_name)
  end

  @spec create_game(binary(), binary(), binary()) :: :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  def create_game(game_id, player_id, player_name) do
    Poker.GameSupervisor.create_game(game_id, player_id, player_name)
  end

  @spec new_shuffled_deck() :: [%Card{}]
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
