defmodule APTaskSchedulerWeb.TasksController do
  use APTaskSchedulerWeb, :controller
  alias APTaskScheduler.Scheduler
  alias APTaskScheduler.Task
  alias APTaskScheduler.ProcessJob
  require Logger


  @doc """
  Display all Tasks grouped by JobId
  """
  def index(conn, _params) do
    payload = Oban
      |> Oban.config()
      |> Oban.Repo.all(Oban.Job)
      |> Enum.map(fn job -> %{
          "state" => job.state,
          "args" => job.args,
          "completed_at" => job.completed_at
      } end)
      |> Enum.group_by(fn job -> job["args"]["job_id"] end)

    json(conn, payload)
  end


  @doc """
  Get Tasks by job_id
  """
  def show(conn, %{"job_id" => job_id}) do
    # get Tasks by job_id
    tasks = APTaskScheduler.Repo.query(job_id)
    # Logger.debug("payload: #{inspect(payload)}")

    case Enum.empty?(tasks) do
      true -> conn
              |> put_status(:not_found)
              |> json(%{error: true, reason: "job_id #{job_id} not found"})
      false -> json(conn, %{tasks: tasks, requestId: job_id})
    end
  end



  @doc """
  Get Tasks by job_id, and render into a Bash script
  """
  def render_script(conn, %{"job_id" => job_id}) do
    # get Tasks by job_id
    tasks = APTaskScheduler.Repo.query(job_id)

    case Enum.empty?(tasks) do
      true -> conn
              |> put_status(:not_found)
              |> json(%{error: true, reason: "job_id #{job_id} not found"})

      false ->
        lines = tasks
          # make sure they are in the proper order
          |> Enum.sort_by(fn task -> task["order"] end)
          # extract the command
          |> Enum.map(fn task -> task["command"] end)
          |> Enum.join("\n")

        script = "#!/usr/bin/env bash\n" <> lines
        Logger.debug("payload: #{inspect(script)}")
        json(conn, %{script: script, requestId: job_id})
    end
  end



  @doc """
  Create a new Job consisting of a Task list
  """
  def create(conn, %{"tasks" => task_maps}) do
    # use requestId as a job id
    requestId = requestId(conn)
    Logger.debug("requestId: #{inspect(requestId)}")

    with {:ok, tasks} <- Task.decode_tasks(task_maps),
         {:ok, ordered} <- Scheduler.order(tasks) do

      # make sure we append all the necessary info
      ordered_tasks_with_index = Task.decorate(ordered, requestId)

      # add the Job in Oban
      ordered_tasks_with_index |> Enum.each(fn task ->
        task
          |> ProcessJob.new()
          |> Oban.insert()
      end)

      Logger.debug("ordered: #{inspect(ordered_tasks_with_index)}")
      json(conn, %{tasks: ordered_tasks_with_index, requestId: requestId})
    else
      {:error, reason} -> json(conn, %{error: reason})
    end
  end


  # ========================================================
  # helpers
  # ========================================================

  # Extract the "x-request-id" response header
  defp requestId(conn), do:
    get_resp_header(conn, "x-request-id") |> List.first


end
