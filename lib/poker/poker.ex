defmodule Poker do
  alias Poker.Player
  alias Poker.GameState
  alias Poker.Card
  alias Ecto.UUID

  def all_in(game_id, player_id) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
    Poker.GameSession.all_in(pid, player_id)
  end

  def call(game_id, player_id, amount) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
    Poker.GameSession.call(pid, player_id, amount)
  end

  def fold(game_id, player_id) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
    Poker.GameSession.fold(pid, player_id)
  end

  def check(game_id, player_id) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
    Poker.GameSession.check(pid, player_id)
  end

  @spec bet(binary(), binary(), binary()) :: %GameState{}
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

  @spec join_game(binary(), %Player{}) :: %GameState{}
  def join_game(game_id, %Player{} = player) do
    [{pid, nil}] = Registry.lookup(Poker.GameRegistry, game_id)
    Poker.GameSession.join(pid, player)
  end

  @spec create_game(binary(), %Player{}) ::
          :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  def create_game(game_id, %Player{} = player) do
    Poker.GameSupervisor.create_game(game_id, player)
  end

  @spec new_shuffled_deck() :: [%Card{}]
  def new_shuffled_deck() do
    suits = ["spade", "heart", "club", "diamond"]

    values = [
      {"2", 2, 2},
      {"3", 3, 3},
      {"4", 4, 4},
      {"5", 5, 5},
      {"6", 6, 6},
      {"7", 7, 7},
      {"8", 8, 8},
      {"9", 9, 9},
      {"10", 10, 10},
      {"J", 11, 11},
      {"Q", 12, 12},
      {"K", 13, 13},
      {"A", 1, 14}
    ]

    for suit <- suits, {literal_value, low_value, high_value} <- values do
      %Poker.Card{
        suit: suit,
        literal_value: literal_value,
        low_numerical_value: low_value,
        high_numerical_value: high_value
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
