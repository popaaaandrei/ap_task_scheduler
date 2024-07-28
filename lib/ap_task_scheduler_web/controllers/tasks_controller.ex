defmodule APTaskSchedulerWeb.TasksController do
  use APTaskSchedulerWeb, :controller
  alias APTaskScheduler.Scheduler
  alias APTaskScheduler.Task
  require Logger


  def index(conn, _params) do
    json(conn, %{index: 123})
    # send_resp(conn, 201, "")

    #   conn
    # |> put_resp_content_type("text/plain")
    # |> send_resp(201, "")
  end

  @doc """
  Create a new Job consisting of a Task lust
  """
  def create(conn, %{"tasks" => task_maps}) do
    with {:ok, tasks} <- Task.decode_tasks(task_maps),
         {:ok, ordered} <- Scheduler.order(tasks) do
      json(conn, ordered)
    else
      {:error, reason} -> json(conn, %{error: reason})
    end
  end

  def create(conn, params) do
    Logger.debug("received params: #{inspect(params)}")
    json(conn, %{error: true})
  end

end
