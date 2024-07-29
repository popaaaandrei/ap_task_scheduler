# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ap_task_scheduler,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :ap_task_scheduler, APTaskSchedulerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: APTaskSchedulerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: APTaskScheduler.PubSub,
  live_view: [signing_salt: "xIa5fCiN"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Ecto config
config :ap_task_scheduler, APTaskScheduler.Repo,
       database: Path.expand("../data/dev.db", Path.dirname(__ENV__.file)),
       # database: :memory,
       pool: Ecto.Adapters.SQL.Sandbox

config :ap_task_scheduler,
       ecto_repos: [APTaskScheduler.Repo]

# Oban configuration
config :ap_task_scheduler, Oban,
   engine: Oban.Engines.Lite,
   queues: [default: 10],
   repo: APTaskScheduler.Repo

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
