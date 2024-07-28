defmodule APTaskScheduler.Repo do
  use Ecto.Repo,
      otp_app: :ap_task_scheduler,
      adapter: Ecto.Adapters.SQLite3
end