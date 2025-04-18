defmodule Oeuvre.Repo.Migrations.CreateSessionPermittedPids do
  alias Oeuvre.Session.PermittedPids
  use Ecto.Migration

  def change do
    create table(:session_permitted_pids) do
      add :prolific_pid, :string

      timestamps(type: :utc_datetime)
    end
  end
end
