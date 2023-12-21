defmodule Poker.GameSession do
  use GenServer
  alias Phoenix.PubSub
  alias Poker.Player

  @impl true
  def handle_call(:read, _from, state) do
    {:reply, state, state}
  end

  def handle_call(
        {:join, %{"player_id" => player_id, "player_name" => player_name}},
        _from,
        state
      ) do
    player =
      Enum.find(state.players, fn player -> player.player_id == player_id end)

    case player do
      nil ->
        state = draw_for_joining_player(state, player_id, player_name)
        PubSub.broadcast!(BetBuddies.PubSub, state.game_id, :update)
        {:reply, state, state}

      _ ->
        {:reply, state, state}
    end
  end

  defp draw_for_joining_player(state, player_id, player_name) do
    %Poker.Draw{drawn_cards: hand, new_deck: new_deck} = Poker.draw(state.dealer.deck, 2)

    Map.update!(state, :players, fn player_list ->
      [
        %Player{player_id: player_id, name: player_name, wallet: 1000, hand: hand}
        | player_list
      ]
    end)
    |> Map.update!(:dealer, fn dealer -> Map.update!(dealer, :deck, fn _ -> new_deck end) end)
  end

  def start_link(arguments) do
    GenServer.start_link(__MODULE__, arguments, name: via(arguments.game_id))
  end

  @impl true
  def init(state) do
    PubSub.subscribe(BetBuddies.PubSub, state.game_id)
    {:ok, state}
  end

  defp via(game_id) do
    {:via, Registry, {Poker.GameRegistry, game_id}}
  end
end
