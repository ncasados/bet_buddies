defmodule Poker.GameState do
  # Put all of the business logic here such as checking the state is correct
  # Stuff such as betting, calling, folding, checking
  # See https://github.com/zblanco/many_ways_to_workflow/blob/master/op_otp/lib/op_otp/

  use Ecto.Schema
  alias Poker.Card
  alias Poker.Player
  alias Poker.GameState

  embedded_schema do
    field :game_id, :string
    field :game_started_at, :utc_datetime
    field :password, :string
    field :game_stage, :string
    embeds_many :dealer_hand, Poker.Card
    embeds_many :dealer_deck, Poker.Card
    field :pot, :integer
    field :side_pot, :integer
    embeds_many :players, Poker.Player
    field :turn_number, :integer
    field :minimum_bet, :integer, default: 0
    field :most_recent_max_bet, :integer, default: 0
    field :big_blind, :integer, default: 800
    field :small_blind, :integer, default: 400
  end

  # Rules

  def is_game_active?(%GameState{game_stage: "ACTIVE"}), do: true
  def is_game_active?(%GameState{game_stage: _}), do: false

  def is_game_lobby?(%GameState{game_stage: "LOBBY"}), do: true
  def is_game_lobby?(%GameState{game_stage: _}), do: false

  def enough_players?(%GameState{players: players}) when length(players) >= 2, do: true
  def enough_players?(%GameState{players: players}) when length(players) < 2, do: false

  @spec is_player_already_joined?(%GameState{}, binary()) :: boolean()
  def is_player_already_joined?(%GameState{} = game_state, player_id) do
    not is_nil(Enum.find(game_state.players, fn player -> player.player_id == player_id end))
  end

  # Transformations

  @spec set_pot(%GameState{}, integer()) :: %GameState{}
  def set_pot(%GameState{} = game_state, pot) do
    Map.update!(game_state, :pot, fn _ -> pot end)
  end

  @spec set_most_recent_max_bet(%GameState{}, integer()) :: %GameState{}
  def set_most_recent_max_bet(%GameState{} = game_state, most_recent_max_bet) do
    Map.update!(game_state, :most_recent_max_bet, fn _ -> most_recent_max_bet end)
  end

  @spec set_minimum_bet(%GameState{}, integer()) :: %GameState{}
  def set_minimum_bet(%GameState{} = game_state, minimum_bet) do
    Map.update!(game_state, :minimum_bet, fn _ -> minimum_bet end)
  end

  @spec set_turn_number(%GameState{}, integer()) :: %GameState{}
  def set_turn_number(%GameState{} = game_state, turn_number) do
    Map.update!(game_state, :turn_number, fn _ -> turn_number end)
  end

  @spec update_players(%GameState{}, [%Player{}]) :: %GameState{}
  def update_players(%GameState{} = game_state, players) do
    Map.update!(game_state, :players, fn _ -> players end)
  end

  @spec update_dealer_deck(%GameState{}, [%Card{}]) :: %GameState{}
  def update_dealer_deck(%GameState{} = game_state, new_deck) do
    Map.update!(game_state, :dealer_deck, fn _ -> new_deck end)
  end

  @spec set_gamestate_to_active(%GameState{}) :: %GameState{}
  def set_gamestate_to_active(%GameState{} = game_state) do
    Map.update!(game_state, :game_stage, fn _ -> "ACTIVE" end)
  end

  @spec add_player_to_state(%GameState{}, binary(), binary()) :: %GameState{}
  def add_player_to_state(%GameState{} = game_state, player_id, player_name) do
    if is_game_lobby?(game_state) do
      Map.update!(game_state, :players, fn player_list ->
        [
          %Player{player_id: player_id, name: player_name, wallet: 20_000, hand: []}
          | player_list
        ]
      end)
    else
      # Maybe return an atom or tuple stating the game isn't in a lobby?
      game_state
    end
  end
end
