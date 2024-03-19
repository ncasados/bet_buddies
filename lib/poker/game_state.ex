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
    # Finish out queue
    embeds_many :player_queue, Poker.Player
    field :turn_number, :integer
    field :minimum_call, :integer, default: 0
    field :minimum_bet, :integer, default: 0
    field :most_recent_max_bet, :integer, default: 0
    field :big_blind, :integer, default: 800
    field :small_blind, :integer, default: 400
    field :hand_log, {:array, :map}, default: []
    field :flop_dealt?, :boolean
    field :turn_dealt?, :boolean
    field :river_dealt?, :boolean
  end

  # Queries

  @spec get_small_blind_player(%GameState{}) :: %Player{}
  def get_small_blind_player(%GameState{} = game_state) do
    Map.get(game_state, :players)
    |> Enum.find(fn %Player{is_small_blind?: is_small_blind} -> is_small_blind end)
  end

  @spec get_big_blind_player(%GameState{}) :: %Player{}
  def get_big_blind_player(%GameState{} = game_state) do
    Map.get(game_state, :players)
    |> Enum.find(fn %Player{is_big_blind?: is_big_blind} -> is_big_blind end)
  end

  @spec get_players_who_need_to_bet(%GameState{}) :: list(%Player{})
  def get_players_who_need_to_bet(%GameState{} = game_state) do
    max_bet = get_max_bet_from_players(game_state)

    Enum.filter(game_state.players, fn %Player{contributed: contributed, is_all_in?: is_all_in} ->
      (contributed < max_bet and not is_all_in) or is_all_in
    end)
  end

  @spec get_players(%GameState{}) :: list(%Player{})
  def get_players(%GameState{} = game_state) do
    Map.get(game_state, :players)
  end

  @spec get_max_bet_from_players(%GameState{}) :: integer()
  def get_max_bet_from_players(%GameState{} = game_state) do
    [first_player | _tail] =
      Map.get(game_state, :players)
      |> Enum.sort_by(fn %Player{contributed: contributed} -> contributed end, :desc)

    Map.get(first_player, :contributed)
  end

  # Rules

  def no_players_in_queue?(%GameState{} = game_state) do
    empty = 0

    player_queue_count =
      Map.get(game_state, :player_queue)
      |> Enum.count()

    player_queue_count == empty
  end

  @spec create_sidepot?(%GameState{}) :: boolean()
  def create_sidepot?(%GameState{} = game_state) do
    players = get_players(game_state)

    not_folded_players =
      Enum.reduce(players, 0, fn
        %Player{} = player, acc -> if player.folded?, do: acc, else: acc + 1
      end)

    not_folded_players >= 3
  end

  @spec is_players_turn?(%GameState{}, %Player{}) :: boolean()
  def is_players_turn?(%GameState{turn_number: turn_number, player_queue: player_queue}, %Player{
        turn_number: player_turn_number,
        player_id: player_id
      }) do
    %Player{player_id: queue_player_id} = top_queue_player = List.first(player_queue)
    queue_player_id == player_id
  end

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

  def add_to_dealer_hand(%GameState{} = game_state, cards) do
    Map.update!(game_state, :dealer_hand, fn prior_hand -> prior_hand ++ cards end)
  end

  def draw_flop(%GameState{} = game_state) do
    dealer_deck = Map.get(game_state, :dealer_deck)
    %{drawn_cards: drawn_cards, new_deck: new_deck} = Poker.draw(dealer_deck, 3)

    GameState.set_dealer_deck(game_state, new_deck)
    |> GameState.add_to_dealer_hand(drawn_cards)
  end

  def set_flop_flopped(%GameState{} = game_state) do
  end

  def move_to_next_stage(%GameState{flop_dealt?: flop_dealt} = game_state) do
    if no_players_in_queue?(game_state) do
      case %{flop: flop_dealt, turn: turn_dealt, river: river_dealt} do
        %{flop: false, turn: false, river: false} ->
          GameState.draw_flop(game_state)
      end
    end
  end

  def remove_player_from_queue(%GameState{} = game_state, %Player{} = folding_player) do
    Map.update!(game_state, :player_queue, fn player_queue ->
      Enum.filter(player_queue, fn %Player{} = player ->
        player.player_id != folding_player.player_id
      end)
    end)
  end

  def set_dealer_deck(%GameState{} = game_state, deck) do
    Map.update!(game_state, :dealer_deck, fn _ -> deck end)
  end >
    @spec draw_for_all_players(%GameState{}) :: %GameState{}

  def draw_for_all_players(%GameState{} = game_state) do
    players = Map.get(game_state, :players)
    original_deck = Map.get(game_state, :dealer_deck)

    %{new_deck: new_deck, players: players} =
      Enum.reduce(players, %{new_deck: original_deck, players: []}, fn player, acc ->
        %{new_deck: new_deck, drawn_cards: drawn_cards} = Poker.draw(acc.new_deck, 2)

        player =
          Map.update!(player, :hand, fn prior_hand ->
            Enum.reduce(drawn_cards, prior_hand, fn new_card, prior_hand ->
              [new_card | prior_hand]
            end)
          end)

        %{new_deck: new_deck, players: [player | acc.players]}
      end)

    GameState.set_players(game_state, players)
    |> GameState.set_dealer_deck(new_deck)
  end

  @spec shuffle_players(%GameState{}) :: %GameState{}
  def shuffle_players(%GameState{} = game_state) do
    shuffled_players =
      Map.get(game_state, :players)
      |> Enum.shuffle()

    Map.update!(game_state, :players, fn _players -> shuffled_players end)
  end

  @spec set_player_queue(%GameState{}, list(%Player{})) :: %GameState{}
  def set_player_queue(%GameState{} = game_state, list_of_players) do
    Map.update!(game_state, :player_queue, fn _queue -> list_of_players end)
  end

  @spec add_player_to_queue(%GameState{}, %Player{}) :: %GameState{}
  def add_player_to_queue(%GameState{} = game_state, %Player{} = player) do
    Map.update!(game_state, :player_queue, fn queue -> queue ++ [player] end)
  end

  @spec add_to_hand_log(%GameState{}, %HandLog{}) :: %GameState{}
  def add_to_hand_log(%GameState{hand_log: hand_log} = game_state, %HandLog{
        player_id: player_id,
        action: action,
        value: value
      }) do
    Map.update!(game_state, :hand_log, fn _ ->
      hand_log ++ [%HandLog{player_id: player_id, action: action, value: value}]
    end)
  end

  @spec update_player_in_players_list(%GameState{}, %Player{}) :: %GameState{}
  def update_player_in_players_list(%GameState{} = game_state, updated_player) do
    Map.update!(game_state, :players, fn players ->
      Enum.map(players, fn
        %Player{} = player when player.player_id == updated_player.player_id -> updated_player
        %Player{} = player -> player
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

  @spec set_players(%GameState{}, [%Player{}]) :: %GameState{}
  def set_players(%GameState{} = game_state, players) do
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
