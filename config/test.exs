import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ap_task_scheduler, APTaskSchedulerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "douQgJLVBS4gPJ+Vi1ztzvcyRYBP4tg1OTnG8fNOUmcvVPDNAiAoXFjGU7OKGdiS",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# prevent Oban from running jobs and plugins during test runs
config :ap_task_scheduler, Oban, testing: :inline

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
