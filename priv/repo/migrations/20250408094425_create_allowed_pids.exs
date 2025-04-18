defmodule Oeuvre.Repo.Migrations.CreateAllowedPids do
  use Ecto.Migration

  def change do
    create table(:allowed_pids) do
      add :prolific_pid, :string

      timestamps(type: :utc_datetime)
    end
  end
end
