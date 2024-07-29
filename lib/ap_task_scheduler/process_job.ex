defmodule APTaskScheduler.ProcessJob do
  use Oban.Worker
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    Logger.info("executing Job: #{inspect(args)}")
    :ok
  end
end