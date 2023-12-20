defmodule BetBuddies.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BetBuddiesWeb.Telemetry,
      BetBuddies.Repo,
      {DNSCluster, query: Application.get_env(:bet_buddies, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BetBuddies.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BetBuddies.Finch},
      # Start a worker by calling: BetBuddies.Worker.start_link(arg)
      # {BetBuddies.Worker, arg},
      # Start to serve requests, typically the last entry
      BetBuddiesWeb.Endpoint,
      {DynamicSupervisor, name: Poker.GameSupervisor, strategy: :one_for_one},
      {Registry, name: Poker.GameRegistry, keys: :unique}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BetBuddies.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BetBuddiesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
