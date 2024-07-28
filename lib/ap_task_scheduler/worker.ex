defmodule APTaskScheduler.Worker do
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: _args} = job) do
    # model = MyApp.Repo.get(MyApp.Business.Man, id)

#    case args do
#      %{"in_the" => "business"} ->
#        IO.inspect(model)
#
#      %{"vote_for" => vote} ->
#        IO.inspect([vote, model])
#
#      _ ->
#        IO.inspect(model)
#    end

    :ok
  end
end