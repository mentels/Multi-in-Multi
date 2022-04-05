defmodule MultiMulti.Application do
  use Application

  alias MultiMulti.Repo

  def start(_, _) do
    children = [Repo]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
