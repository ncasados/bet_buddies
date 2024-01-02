# BetBuddies

<img src="./priv/static/images/bet_buddies.png" style="width:60%" />

## To start it

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

At [`localhost:4000`](http://localhost:4000) you can create a game or join a game.

You need only your name to create a game. In the URL you'll find a game id like `localhost:4000/game/big-old-long-id`

Give the other player the `big-old-long-id` and with their name, they'll be able to join the game.

Some features are still missing.

# Features
- [x] Game can be created
- [x] Players can join game
- [x] Host can start game
- [ ] A round of poker can be played