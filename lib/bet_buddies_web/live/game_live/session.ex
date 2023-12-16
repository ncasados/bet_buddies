defmodule BetBuddiesWeb.GameLive.Session do
  use Phoenix.LiveView
  use Phoenix.Component

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

  def render(assigns) do
    ~H"""
    <body style="background-position: center;
      background-image: url(https://community-cdn.frontier.co.uk/elite-dangerous/3.3/wallpapers/Elite_wallpaper_4k_19.jpg);">
      <div class="flex flex-col justify-between h-screen p-2">
        <.other_players />
        <.dealer />
        <.player />
      </div>
    </body>
    """
  end

  def other_players(assigns) do
    ~H"""
    <div class="flex flex-row justify-start sm:justify-center space-x-2 overflow-auto">
      <.other_player />
      <.other_player />
      <.other_player />
      <.other_player />
    </div>
    """
  end

  def card(assigns) do
    ~H"""
    <div class="flex flex-col h-16 w-11 sm:w-16 sm:h-24 border shadow-lg justify-between p-1 bg-white">
      <div class="flex flex-row">
        <div>♠A</div>
      </div>
      <div class="flex flex-row-reverse">
        <div>♠A</div>
      </div>
    </div>
    """
  end

  def card_back(assigns) do
    ~H"""
    <div class="flex flex-col border shadow-lg rounded p-1.5 h-16 w-11 sm:w-16 sm:h-24 justify-center bg-red-200">
      <img
        src="/images/card_back.png"
        class="border-2 border-red-100 rounded"
      />
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
            <.card />
            <.card />
            <.card_back />
            <.card_back />
            <.card_back />
          </div>
          <div class="flex flex-row space-x-2 justify-evenly">
            <div class="flex flex-col">
              Pot: $12,000
            </div>
            <div class="flex flex-col">
              Side Pot: $1,000
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
          <div class="flex-row text-center">My Name</div>
          <div class="flex-row bg-gray-300 rounded p-1 text-center">$1,000</div>
          <div class="flex-row space-y-1">
            <button class="bg-[#d1a919] text-neutral-50 w-20 rounded p-1 text-center">Fold</button>
            <button class="bg-[#d1a919] text-neutral-50 w-20 rounded p-1 text-center">Check</button>
            <button class="bg-[#d1a919] text-neutral-50 w-20 rounded p-1 text-center">Bet</button>
            <button class="bg-[#d1a919] text-neutral-50 w-20 rounded p-1 text-center">Call</button>
            <button class="bg-[#d1a919] text-neutral-50 w-20 rounded p-1 text-center">Raise</button>
          </div>
          <div class="flex flex-row justify-center">
            <input type="range" class="w-full" min="0" max="1000" value="0" />
          </div>
          <div class="flex flex-row space-x-2 justify-center">
            <.card />
            <.card />
          </div>
        </div>
      </div>
    </div>
    """
  end

  def other_player(assigns) do
    ~H"""
    <div class="flex border shadow-lg rounded p-2 bg-white">
      <div class="flex-col space-y-2">
        <div class="flex-row text-center text-xs sm:text-base">Player Name</div>
        <div class="flex-row bg-gray-300 rounded p-1 text-center text-xs sm:text-base">$1,000</div>
        <div class="flex-row bg-[#c9af8b] rounded p-1 text-center text-xs sm:text-base">Raise $50/call $50/fold/check</div>
        <div class="flex flex-row space-x-2 justify-center">
          <.card_back />
          <.card_back />
        </div>
      </div>
    </div>
    """
  end
end
