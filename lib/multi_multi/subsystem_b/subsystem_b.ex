defmodule MultiMulti.SubsystemB do
  @moduledoc """
  Some subsystem of the app.
  """

  alias Ecto.Multi
  alias MultiMulti.Repo

  def do_some_work(opts \\ [fail_tx?: false]) do
    Multi.new()
    |> Multi.run(:step, fn _repo, _changes ->
      if opts[:fail_tx?] do
        {:error, :reason}
      else
        {:ok, :value}
      end
    end)
    |> Repo.transaction()
  end
end
