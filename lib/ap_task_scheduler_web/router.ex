defmodule APTaskSchedulerWeb.Router do
  use APTaskSchedulerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", APTaskSchedulerWeb do
    pipe_through :api

    get "/tasks", TasksController, :index
    get "/tasks/:job_id", TasksController, :show
    post "/tasks", TasksController, :create

  end
end
