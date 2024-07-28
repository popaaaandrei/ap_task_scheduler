defmodule APTaskScheduler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      APTaskSchedulerWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:ap_task_scheduler, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: APTaskScheduler.PubSub},
      # Start a worker by calling: APTaskScheduler.Worker.start_link(arg)
      # {APTaskScheduler.Worker, arg},
      # Start to serve requests, typically the last entry
      APTaskSchedulerWeb.Endpoint,

      APTaskScheduler.Repo,
      {Oban, Application.fetch_env!(:ap_task_scheduler, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: APTaskScheduler.Supervisor]
    # {:ok, _} = Supervisor.start_link(children, opts)
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    APTaskSchedulerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

end
