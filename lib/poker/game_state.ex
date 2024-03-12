defmodule Poker.GameState do
  # Put all of the business logic here such as checking the state is correct
  # Stuff such as betting, calling, folding, checking
  # See https://github.com/zblanco/many_ways_to_workflow/blob/master/op_otp/lib/op_otp/

  use Ecto.Schema
  alias Poker.Card
  alias Poker.Player
  alias Poker.GameState
  alias Poker.HandLog

  embedded_schema do
    field :game_id, :string
    field :game_started_at, :utc_datetime
    field :password, :string
    field :game_stage, :string
    embeds_many :dealer_hand, Poker.Card
    embeds_many :dealer_deck, Poker.Card
    field :main_pot, :integer, default: 0
    field :side_pots, {:array, :map}, default: []
    embeds_many :players, Poker.Player
    field :turn_number, :integer
    field :minimum_call, :integer, default: 0
    field :minimum_bet, :integer, default: 0
    field :most_recent_max_bet, :integer, default: 0
    field :big_blind, :integer, default: 800
    field :small_blind, :integer, default: 400
    field :hand_log, {:array, :map}, default: []
  end

  # Queries

  def get_players(%GameState{} = game_state) do
    Map.get(game_state, :players)
  end

  # Rules

  @spec create_sidepot?(%GameState{}) :: boolean()
  def create_sidepot?(%GameState{} = game_state) do
    players = get_players(game_state)
    not_folded_players = Enum.reduce(players, 0, fn
      %Player{} = player, acc -> if player.folded?, do: acc, else: acc + 1
    end)
    not_folded_players >= 3
  end

  def everyone_bet_the_same?(%GameState{} = game_state) do
    game_state
  end

  @spec is_players_turn?(%GameState{}, %Player{}) :: boolean()
  def is_players_turn?(%GameState{turn_number: turn_number}, %Player{
        turn_number: player_turn_number
      })
      when turn_number == player_turn_number,
      do: true

  def is_players_turn?(%GameState{turn_number: turn_number}, %Player{
        turn_number: player_turn_number
      })
      when turn_number != player_turn_number,
      do: false

  @spec is_game_active?(%GameState{}) :: boolean()
  def is_game_active?(%GameState{game_stage: "ACTIVE"}), do: true
  def is_game_active?(%GameState{game_stage: _}), do: false

  @spec is_game_lobby?(%GameState{}) :: boolean()
  def is_game_lobby?(%GameState{game_stage: "LOBBY"}), do: true
  def is_game_lobby?(%GameState{game_stage: _}), do: false

  @spec enough_players?(%GameState{}) :: boolean()
  def enough_players?(%GameState{players: players}) when length(players) >= 2, do: true
  def enough_players?(%GameState{players: players}) when length(players) < 2, do: false

  @spec is_player_already_joined?(%GameState{}, %Player{}) :: boolean()
  def is_player_already_joined?(%GameState{} = game_state, %Player{player_id: player_id}) do
    not is_nil(Enum.find(game_state.players, fn player -> player.player_id == player_id end))
  end

  # Transformations

  @spec add_to_hand_log(%GameState{}, %HandLog{}) :: %GameState{}
  def add_to_hand_log(%GameState{hand_log: hand_log} = game_state, %HandLog{player_id: player_id, action: action, value: value}) do
    Map.update!(game_state, :hand_log, fn _ -> hand_log ++ [%HandLog{player_id: player_id, action: action, value: value}] end)
  end

  @spec update_player_by_index(%GameState{}, %Player{}, integer()) :: %GameState{}
  def update_player_by_index(%GameState{} = game_state, updated_player, player_index) do
    Map.update!(game_state, :players, fn players ->
      List.update_at(players, player_index, fn _player ->
        updated_player
      end)
    end)
  end

  @spec increment_turn_number(%GameState{}) :: %GameState{}
  def increment_turn_number(%GameState{players: players} = game_state) do
    Map.update!(game_state, :turn_number, fn n ->
      if n + 1 > length(players), do: 1, else: n + 1
    end)
  end

  @spec add_to_main_pot(%GameState{}, integer()) :: %GameState{}
  def add_to_main_pot(%GameState{} = game_state, to_add) do
    Map.update!(game_state, :main_pot, fn pot -> pot + to_add end)
  end

  @spec set_most_recent_max_bet(%GameState{}, integer()) :: %GameState{}
  def set_most_recent_max_bet(%GameState{} = game_state, most_recent_max_bet) do
    Map.update!(game_state, :most_recent_max_bet, fn _ -> most_recent_max_bet end)
  end

  @spec set_minimum_call(%GameState{}, integer()) :: %GameState{}
  def set_minimum_call(%GameState{} = game_state, minimum_call) do
    Map.update!(game_state, :minimum_call, fn _ -> minimum_call end)
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

  @spec add_player_to_state(%GameState{}, %Player{}) :: %GameState{}
  def add_player_to_state(%GameState{} = game_state, %Player{} = player) do
    if is_game_lobby?(game_state) do
      Map.update!(game_state, :players, fn player_list ->
        [
          player
          | player_list
        ]
      end)
    else
      # Maybe return an atom or tuple stating the game isn't in a lobby?
      game_state
    end
  end
end
