defmodule BetBuddiesWeb.GameLive.Index do
  use Phoenix.LiveView
  use Phoenix.Component
  alias Poker.GameState
  alias Poker.Player
  alias Phoenix.PubSub
  use BetBuddiesWeb, :html

  def mount(
        %{"game_id" => game_id} = _params,
        %{"player_id" => player_id} = _session,
        socket
      ) do
    PubSub.subscribe(BetBuddies.PubSub, game_id)

    %GameState{
      players: players,
      game_stage: game_stage,
      turn_number: turn_number,
      main_pot: main_pot,
      side_pots: side_pots,
      minimum_bet: minimum_bet,
      most_recent_max_bet: most_recent_max_bet
    } = game_state = Poker.get_game_state(game_id)

    %Player{bet: players_bet} = player = find_player(players, player_id)

    other_players = players -- [player]

    socket =
      assign(socket, :game_id, game_id)
      |> assign(:game_stage, game_stage)
      |> assign(:player, player)
      |> assign(:other_players, other_players)
      |> assign(:bet_slider_value, minimum_bet)
      |> assign(:turn_number, turn_number)
      |> assign(:main_pot, main_pot)
      |> assign(:side_pots, if(side_pots == [], do: 0, else: side_pots))
      |> assign(:minimum_bet, minimum_bet)
      |> assign(:minimum_call, most_recent_max_bet - players_bet)
      |> assign(:all_in?, player.wallet <= minimum_bet)
      |> assign(:game_state, game_state)

    {:ok, socket}
  end

  def handle_event("fold", _params, socket) do
    Poker.fold(socket.assigns.game_id, socket.assigns.player.player_id)
    {:noreply, socket}
  end

  def handle_event("bet", %{"value" => amount} = _params, socket) do
    Poker.bet(socket.assigns.game_id, socket.assigns.player.player_id, amount)
    {:noreply, socket}
  end

  def handle_event("check", _params, socket) do
    Poker.check(socket.assigns.game_id, socket.assigns.player.player_id)
    {:noreply, socket}
  end

  def handle_event("start-game", _params, socket) do
    Poker.start_game(socket.assigns.game_id)
    {:noreply, socket}
  end

  def handle_event("bet-changed", %{"bet-value" => bet_value} = _params, socket) do
    wallet = to_string(socket.assigns.player.wallet)

    socket =
      assign(socket, :bet_slider_value, bet_value)

    IO.inspect(wallet)

    if bet_value == wallet do
      IO.inspect("All in boy")
      socket = assign(socket, :all_in?, true)
      {:noreply, socket}
    else
      socket = assign(socket, :all_in?, false)
      {:noreply, socket}
    end
  end

  def handle_event("call", %{"value" => amount} = _params, socket) do
    Poker.call(socket.assigns.game_id, socket.assigns.player.player_id, amount)
    {:noreply, socket}
  end

  def handle_info(:update, socket) do
    game_id = socket.assigns.game_id
    player = socket.assigns.player

    %GameState{
      players: players,
      game_stage: game_stage,
      turn_number: turn_number,
      main_pot: main_pot,
      minimum_bet: minimum_bet,
      most_recent_max_bet: most_recent_max_bet
    } =
      Poker.get_game_state(game_id)

    %Player{bet: players_bet} = player = find_player(players, player.player_id)
    other_players = players -- [player]

    socket =
      assign(socket, :game_id, game_id)
      |> assign(:game_stage, game_stage)
      |> assign(:player, player)
      |> assign(:other_players, other_players)
      |> assign(:turn_number, turn_number)
      |> assign(:main_pot, main_pot)
      |> assign(:minimum_bet, minimum_bet)
      |> assign(:minimum_call, most_recent_max_bet - players_bet)
      |> assign(:bet_slider_value, minimum_bet)
      |> assign(:all_in?, player.wallet <= minimum_bet)

    {:noreply, socket}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @spec find_player([%Player{}], binary()) :: %Player{}
  def find_player(players, player_id) do
    Enum.find(players, fn %Poker.Player{} = player -> player.player_id == player_id end)
  end

  def render(assigns) do
    ~H"""
    <div style={
      "background-position: center;
      background-image: url(#{~p"/images/background.jpg"});"}>
      <div class="flex flex-col justify-between h-screen p-2">
        <.other_players players={@other_players} game_stage={@game_stage} />
        <%= case assigns do %>
          <% %{game_stage: "LOBBY", player: %{is_host?: true}} -> %>
            <.game_start game_id={@game_id} />
          <% %{game_stage: "LOBBY", player: %{is_host?: false}} -> %>
            <div class="flex justify-center">
              <div class="bg-white p-4 rounded text-center max-w-xs">
                <p class="animate-bounce">Waiting for host to start game...</p>
              </div>
            </div>
          <% _ -> %>
            <.dealer main_pot={@main_pot} side_pots={@side_pots} />
        <% end %>
        <.player
          player={@player}
          bet_slider_value={@bet_slider_value}
          game_stage={@game_stage}
          turn_number={@turn_number}
          minimum_bet={@minimum_bet}
          minimum_call={@minimum_call}
          all_in?={@all_in?}
        />
      </div>
    </div>
    """
  end

  def game_start(assigns) do
    ~H"""
    <form phx-submit="start-game" class="flex justify-center">
      <button
        type="submit"
        name="start-game-button"
        id="start-game-button"
        class="bg-purple-500 p-4 rounded-3xl text-white"
        value={@game_id}
      >
        Start Game
      </button>
    </form>
    """
  end

  def other_players(assigns) do
    ~H"""
    <div class="flex flex-row justify-start sm:justify-center space-x-2 overflow-auto">
      <%= for player <- assigns.players do %>
        <.other_player player={player} game_stage={@game_stage} />
      <% end %>
    </div>
    """
  end

  def card(assigns) do
    card =
      case Map.get(assigns, :card) do
        nil -> %{}
        card -> card
      end

    suit =
      case card.suit do
        nil -> ""
        "spade" -> "♠"
        "heart" -> "♥"
        "diamond" -> "♦"
        "club" -> "♣"
      end

    color =
      case card.suit do
        nil -> ""
        "spade" -> "text-[#000000]"
        "heart" -> "text-[#FF0000]"
        "club" -> "text-[#000000]"
        "diamond" -> "text-[#FF0000]"
      end

    assigns =
      assign(assigns, :color, color)
      |> assign(:suit, suit)
      |> assign(:card, card)

    ~H"""
    <div class="flex flex-col h-16 w-11 sm:w-16 sm:h-24 border shadow-lg justify-between p-1 bg-white">
      <div class="flex flex-row">
        <div class={@color}><%= @suit %><%= @card.value %></div>
      </div>
      <div class="flex flex-row-reverse">
        <div class={@color}><%= @suit %><%= @card.value %></div>
      </div>
    </div>
    """
  end

  def card_back(assigns) do
    ~H"""
    <div class="flex flex-col border shadow-lg rounded p-1.5 h-16 w-11 sm:w-16 sm:h-24 justify-center bg-red-200">
      <img src="/images/card_back.png" class="border-2 border-red-100 rounded" />
    </div>
    """
  end

  def dealer(assigns) do
    ~H"""
    <div class="flex flex-row justify-start sm:justify-center overflow-x-auto space-x-2">
      <div class="flex border shadow-lg rounded p-2 bg-white">
        <div class="flex-col space-y-2">
          <div class="flex-row text-center">Dealer</div>
          <div class="flex flex-row space-x-2 justify-center">
            <.card_back />
            <.card_back />
            <.card_back />
            <.card_back />
            <.card_back />
          </div>
          <div class="flex flex-row space-x-2 justify-evenly">
            <div class="flex flex-col">
              Main Pot: $<%= @main_pot %>
            </div>
            <div class="flex flex-col">
              Side Pot: $<%= @side_pots %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def player(assigns) do
    ~H"""
    <div class="flex flex-row justify-center space-x-2">
      <div class="flex border shadow-lg rounded p-2 bg-white">
        <div class="flex-col space-y-2">
          <div class="flex-row text-center"><%= @player.name %></div>
          <div class="flex-row bg-gray-300 rounded p-1 text-center">$<%= @player.wallet %></div>
          <%= case assigns do %>
            <% %{game_stage: "LOBBY"} -> %>
              <div></div>
            <% %{turn_number: turn_number} -> %>
              <%= case turn_number == @player.turn_number do %>
                <% false -> %>
                  <div></div>
                <% true -> %>
                  <form>
                    <div class="flex-row space-y-1">
                      <button
                        class="bg-[#d1a919] text-neutral-50 w-20 rounded p-1 text-center"
                        onclick="event.preventDefault()"
                        phx-click="fold"
                      >
                        Fold
                      </button>
                      <button
                        class="bg-[#d1a919] text-neutral-50 w-20 rounded p-1 text-center"
                        onclick="event.preventDefault()"
                        phx-click="check"
                      >
                        Check
                      </button>
                      <%= if @all_in? do %>
                        <button
                          class="bg-[#d1a919] text-neutral-50 w-20 rounded p-1 text-center"
                          onclick="event.preventDefault()"
                          phx-click="all_in"
                          value={@bet_slider_value}
                        >
                        All In
                        </button>
                      <% else %>
                        <button
                          class="bg-[#d1a919] text-neutral-50 w-20 rounded p-1 text-center"
                          onclick="event.preventDefault()"
                          phx-click="bet"
                          value={@bet_slider_value}
                        >
                        Bet
                        </button>
                      <% end %>
                      <button
                        class="bg-[#d1a919] text-neutral-50 w-20 rounded p-1 text-center"
                        onclick="event.preventDefault()"
                        phx-click="call"
                        value={@minimum_call}
                      >
                        Call
                      </button>
                    </div>
                    <div class="flex flex-row justify-center space-x-2">
                      <input
                        id="bet-slider"
                        name="bet-value"
                        type="range"
                        class="w-full"
                        min={@minimum_bet}
                        max={@player.wallet}
                        value={@minimum_bet}
                        phx-change="bet-changed"
                      />
                      <p id="slider-value" class="w-16">$<%= @bet_slider_value %></p>
                    </div>
                  </form>
              <% end %>
              <div class="flex flex-row space-x-2 justify-center">
                <.card card={List.first(@player.hand)} />
                <.card card={List.last(@player.hand)} />
              </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def other_player(assigns) do
    ~H"""
    <div class="flex border shadow-lg rounded p-2 bg-white">
      <div class="flex-col space-y-2">
        <div class="flex-row text-center text-xs sm:text-base"><%= @player.name %></div>
        <div class="flex-row bg-gray-300 rounded p-1 text-center text-xs sm:text-base">
          $<%= @player.wallet %>
        </div>
        <%= if @game_stage == "LOBBY" do %>
        <% else %>
          <div class="flex-row bg-[#c9af8b] rounded p-1 text-center text-xs sm:text-base">
            Next Action
          </div>
          <div class="flex flex-row space-x-2 justify-center">
            <.card_back />
            <.card_back />
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
