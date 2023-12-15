defmodule BetBuddies.Repo do
  use Ecto.Repo,
    otp_app: :bet_buddies,
    adapter: Ecto.Adapters.Postgres
end
