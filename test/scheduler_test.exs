defmodule SchedulerTest do
  alias APTaskScheduler.Scheduler
  alias APTaskScheduler.Task
  use ExUnit.Case

  test "consistent json" do
    json = """
    {
        "tasks": [
            {
                "name": "task-1",
                "command": "touch /tmp/file1"
            },
            {
                "name": "task-2",
                "command": "cat /tmp/file1",
                "requires": [
                    "task-3"
                ]
            },
            {
                "name": "task-3",
                "command": "echo 'Hello World!' > /tmp/file1",
                "requires": [
                    "task-1"
                ]
            },
            {
                "name": "task-4",
                "command": "rm /tmp/file1",
                "requires": [
                    "task-2",
                    "task-3"
                ]
            }
        ]
    }
    """

    tasks = Task.decode_tasks(json)
    {:ok, _ordered_tasks} = Scheduler.order(tasks)
  end


  test "references are inconsistent" do
    json = """
    {
        "tasks": [
            {
                "name": "task-1",
                "command": "touch /tmp/file1"
            },
            {
                "name": "task-2",
                "command": "cat /tmp/file1",
                "requires": [
                    "task-3"
                ]
            },
            {
                "name": "task-3",
                "command": "echo 'Hello World!' > /tmp/file1",
                "requires": [
                    "task-1"
                ]
            },
            {
                "name": "task-4",
                "command": "rm /tmp/file1",
                "requires": [
                    "task-2",
                    "task-5"
                ]
            }
        ]
    }
    """

    tasks = Task.decode_tasks(json)
    assert Scheduler.order(tasks) == {:error, :invalid_references}
  end


  test "cycles present" do
    json = """
    {
        "tasks": [
            {
                "name": "task-1",
                "command": "touch /tmp/file1"
            },
            {
                "name": "task-2",
                "command": "cat /tmp/file1",
                "requires": [
                    "task-3"
                ]
            },
            {
                "name": "task-3",
                "command": "echo 'Hello World!' > /tmp/file1",
                "requires": [
                    "task-4"
                ]
            },
            {
                "name": "task-4",
                "command": "rm /tmp/file1",
                "requires": [
                    "task-2"
                ]
            }
        ]
    }
    """

    tasks = Task.decode_tasks(json)
    assert Scheduler.order(tasks) == {:error, :dependencies_have_cycles}
  end
end
