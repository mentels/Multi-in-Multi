defmodule MultiMulti do
  @moduledoc """
  Documentation for `MultiMulti`.
  """

  require Logger

  import Ecto.Query

  alias Ecto.Multi
  alias MultiMulti.Repo

  alias MultiMulti.SubsystemA
  alias MultiMulti.SubsystemB

  @doc """
  Wrap Multis in Multi.

  If an inner Multi fails, trying to continue with the outer Multi raises an exception.
  ** (RuntimeError) operation :rollback is manually rolling back, which is not supported by Ecto.Multi

  If an inner Multi fails, we MUST return {:error, sth}, then we're fine.

  If an inner Multi fails, and we try to do some rescue code before finish the step we get the `DbConnection.Connection.Error`
  ** (DBConnection.ConnectionError) transaction rolling back
    (ecto_sql 3.7.2) lib/ecto/adapters/sql.ex:760: Ecto.Adapters.SQL.raise_sql_call_error/1

  With `ret` it just complains about bad ecto callback.
  """
  def run_in_multi(opts \\ []) do
    Multi.new()
    |> Multi.run(:subsystem_a, fn _, _ ->
      case SubsystemA.do_some_work(opts[:subsystem_a]) do
        {:ok, _} = ret ->
          ret

        {:error, step, reason, _changes} = ret ->
          Logger.error("Subsystem A failed step=#{step}, reason=#{reason}")

          case opts[:subsystem_a_return] do
            :ignore ->
              {:ok, :return_ok_as_if_we_could_continue}

            :error ->
              {:error, :proper_error}

            :recover ->
              do_recovery_work()

            _ ->
              ret
          end
      end
    end)
    |> Multi.run(:subsystem_b, fn _, _ ->
      case SubsystemB.do_some_work(opts[:subsystem_b]) do
        {:ok, _} = ret ->
          ret

        {:error, step, reason, _changes} ->
          Logger.error("Subsystem B failed step=#{step}, reason=#{reason}")
          {:ok, reason}
      end
    end)
    |> Repo.transaction()
  end

  defp do_recovery_work(), do: Repo.all(from("some_table", select: [:non_existent_field]))
end
