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
      |> Enum.group_by(fn job -> job["args"]["requestId"] end)

    json(conn, payload)
  end


  @doc """
  Get Tasks by job_id
  """
  def show(conn, %{"job_id" => job_id}) do
    # get Tasks by job_id
    payload = APTaskScheduler.Repo.query(job_id)
    # Logger.debug("payload: #{inspect(payload)}")
    json(conn, %{tasks: payload, requestId: job_id})
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
      ordered_maps = ordered
        |> Enum.with_index()
        |> Enum.map(fn {task, index} ->
            %Task{
              id: task.id,
              name: task.name,
              command: task.command,
              requires: task.requires,
              order: index,
              job_id: requestId
            }
          end)

      # add the Job in Oban
      ordered_maps |> Enum.each(fn task ->
        task
          |> ProcessJob.new()
          |> Oban.insert()
      end)

      Logger.debug("ordered: #{inspect(ordered_maps)}")
      json(conn, %{tasks: ordered_maps, requestId: requestId})
    else
      {:error, reason} -> json(conn, %{error: reason})
    end
  end


  # ========================================================
  # helpers
  # ========================================================

  @doc_private """
  Extract the "x-request-id" response header
  """
  defp requestId(conn), do:
    get_resp_header(conn, "x-request-id") |> List.first


end
