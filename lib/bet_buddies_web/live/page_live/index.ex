defmodule BetBuddiesWeb.PageLive.Index do
  use Phoenix.LiveView
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <body style="background-image: url(https://community-cdn.frontier.co.uk/elite-dangerous/3.3/wallpapers/Elite_wallpaper_4k_19.jpg)">
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
    <div class="flex flex-row justify-center space-x-2">
      <.other_player />
      <.other_player />
      <.other_player />
    </div>
    """
  end

  def card(assigns) do
    ~H"""
    <div class="flex flex-col w-16 h-24 border shadow-lg justify-between p-1 bg-white">
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
    <div class="flex flex-col border shadow-lg rounded p-1 w-16 h-24 justify-center bg-gray-600">
      <img
        src="https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/2ec3209a-8afc-46a7-8d51-f0bfbaac5eea/dg3cus7-58b20d70-0f81-4af5-a1ba-4aaf2aebe0c9.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzJlYzMyMDlhLThhZmMtNDZhNy04ZDUxLWYwYmZiYWFjNWVlYVwvZGczY3VzNy01OGIyMGQ3MC0wZjgxLTRhZjUtYTFiYS00YWFmMmFlYmUwYzkucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.hSXGVEJMGiUhx-gOgisLC4tMnlLKvrMWBJyFmFVYFCE"
        class="border-2 border-red-800 rounded"
      />
    </div>
    """
  end

  def dealer(assigns) do
    ~H"""
    <div class="flex flex-row justify-center space-x-2">
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
          <div class="flex-row">
            <button class="bg-green-200 rounded p-1 text-center">Fold</button>
            <button class="bg-green-200 rounded p-1 text-center">Check</button>
            <button class="bg-green-200 rounded p-1 text-center">Bet</button>
            <button class="bg-green-200 rounded p-1 text-center">Call</button>
            <button class="bg-green-200 rounded p-1 text-center">Raise</button>
          </div>
          <div class="flex flex-row">
            <input type="text" />
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
        <div class="flex-row text-center">Player Name</div>
        <div class="flex-row bg-gray-300 rounded p-1 text-center">$1,000</div>
        <div class="flex-row bg-green-200 rounded p-1 text-center">Raise $50/call $50/fold/check</div>
        <div class="flex flex-row space-x-2 justify-center">
          <.card_back />
          <.card_back />
        </div>
      </div>
    </div>
    """
  end
end
