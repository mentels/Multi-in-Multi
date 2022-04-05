defmodule MultiMulti.Repo do
  use Ecto.Repo,
    otp_app: :multi_multi,
    adapter: Ecto.Adapters.Postgres
end
