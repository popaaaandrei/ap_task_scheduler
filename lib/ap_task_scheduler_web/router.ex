defmodule APTaskSchedulerWeb.Router do
  use APTaskSchedulerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", APTaskSchedulerWeb do
    pipe_through :api

    get "/tasks", TasksController, :index
    post "/tasks", TasksController, :create

    # get "/reviews/:id", TasksController, :show

  end
end
