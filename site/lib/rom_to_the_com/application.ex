defmodule RomToTheCom.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RomToTheComWeb.Telemetry,
      RomToTheCom.Repo,
      {DNSCluster, query: Application.get_env(:rom_to_the_com, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RomToTheCom.PubSub},
      # Start a worker by calling: RomToTheCom.Worker.start_link(arg)
      # {RomToTheCom.Worker, arg},
      # Start to serve requests, typically the last entry
      RomToTheComWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RomToTheCom.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RomToTheComWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
