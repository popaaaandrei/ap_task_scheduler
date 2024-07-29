defmodule APTaskScheduler.Repo do
  use Ecto.Repo,
      otp_app: :ap_task_scheduler,
      adapter: Ecto.Adapters.SQLite3


  @doc """
  Get all Tasks based on JobId
  """
  def query(job_id) when is_bitstring(job_id) do
    query = """
    SELECT args FROM oban_jobs
    WHERE args->>'job_id' = '#{job_id}'
    """

    with {:ok, result} <- Oban
                          |> Oban.config()
                          |> Oban.Repo.query(query) do
      result.rows
      |> List.flatten()
      |> Enum.map(fn entry ->
           case Jason.decode(entry) do
             {:ok, json} -> json
             error -> error
           end
         end)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def query(_else), do: {:error, :wrong_input}

end