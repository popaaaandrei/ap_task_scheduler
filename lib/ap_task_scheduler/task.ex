defmodule APTaskScheduler.Task do
  alias APTaskScheduler.Task
  require Logger

  @moduledoc """
  task.name is not stable enough for an identifier
  that's why we introduce a deterministic id based on the task.name
  """

  @enforce_keys [:name, :command]
  @derive Jason.Encoder
  defstruct [
    :id,
    :name,
    :command,
    requires: []
  ]

  @typedoc "Task"
  @type t() :: %__MODULE__{
          id: String.t() | nil,
          name: String.t(),
          command: String.t(),
          requires: list() | []
        }

  # ========================================================
  # api
  # ========================================================

  def deterministic_id(input), do: :erlang.phash2(input) |> to_string()


  def decode_tasks(task_list) when is_list(task_list) do
    tasks = task_list |> Enum.map(&map_to_task/1)
    {:ok, tasks}
  end

  def decode_tasks(json) when is_binary(json) do
    case Jason.decode(json) do
      {:ok, %{"tasks" => list}} -> list |> Enum.map(&map_to_task/1)
      {:error, reason} -> {:error, reason}
    end
  end

  # ========================================================
  # helpers
  # ========================================================

  defp map_to_task(%{"name" => name, "command" => command, "requires" => requires}) do
    %Task{
      id: name |> deterministic_id(),
      name: name,
      command: command,
      requires: requires
    }
  end

  defp map_to_task(%{"name" => name, "command" => command}) do
    %Task{
      id: name |> deterministic_id(),
      name: name,
      command: command,
      requires: []
    }
  end

  defp map_to_task(_invalid) do
    {:error, "Invalid task format"}
  end
end
