defmodule Oeuvre.Repo do
  use Ecto.Repo,
    otp_app: :oeuvre,
    adapter: Ecto.Adapters.Postgres
end
