import Config

config :multi_multi, ecto_repos: [MultiMulti.Repo]

config :multi_multi, MultiMulti.Repo,
  database: "multi_multi",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
