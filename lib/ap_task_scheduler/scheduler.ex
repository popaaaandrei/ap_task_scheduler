defmodule APTaskScheduler.Scheduler do
  import Enum
  alias APTaskScheduler.Task
  require Logger


  # ========================================================
  # api
  # ========================================================

  @doc """
  Orders a list of Tasks based on their dependencies
  """
  @spec order(list()) :: {:ok, list()} | {:error, atom()}
  def order(tasks) when is_list(tasks) do

    # check if the tasks are consistent
    with {:ok, tasks} <- check_consistency(tasks),
        # construct dependency graph
        {:ok, graph} <- graph(tasks),
        # arrange Tasks in the topological order
        {:ok, sorted} <- arrange(tasks, Graph.topsort(graph)) do

        {:ok, sorted}
    else
      error -> error
    end
  end


  # ========================================================
  # helpers
  # ========================================================


  # Create a directed Graph from all tasks
  defp graph(tasks) when is_list(tasks) do
    # 1) create the dependency list
    dependencies = tasks
      |> map(fn task ->
        # prerequisite -> task
        task.requires |> map(fn requirement ->
          # create the id the same way
          id = requirement |> Task.deterministic_id()
          {id, task.id}
        end)
      end)
      # get all dependencies as a list
      |> List.flatten()

    # 2) create new directed graph, add all edges
    graph = dependencies |> reduce(Graph.new(type: :directed), fn {from, to}, graph ->
      Graph.add_edge(graph, from, to)
    end)

    # 3) check for cycles
    case Graph.is_cyclic?(graph) do
      true -> {:error, :dependencies_have_cycles}
      false -> {:ok, graph}
    end
  end


  # Gets a list of Tasks and checks whether all references are defined properly
  @spec check_consistency(list()) :: {:ok, list()} | {:error, atom()}
  defp check_consistency(tasks) when is_list(tasks) do
    task_names = tasks |> map(fn t -> t.name end)

    # all requirements need to exist within the task_names
    consistent = tasks |> all?(fn task ->
      task.requires |> all?(fn requirement -> member?(task_names, requirement) end)
    end)

    case consistent do
      true -> {:ok, tasks}
      false -> {:error, :invalid_references}
    end
  end


  # Arranges a list of Tasks in the order specified by order param
  @spec arrange(list(), list()) :: {:ok, list()} | {:error, atom()}
  defp arrange(tasks, order) when is_list(tasks) and is_list(order) do
    sorted = order
    |> map(fn id -> find(tasks, :not_found, fn task -> task.id == id end) end)

    case sorted |> member?(:not_found) do
      true -> {:error, :not_found}
      false -> {:ok, sorted}
    end
  end


  defp arrange(tasks, false) when is_list(tasks), do:
    {:error, :topological_ordering_not_possible}


end
