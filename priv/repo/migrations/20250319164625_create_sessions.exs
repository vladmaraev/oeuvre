defmodule Oeuvre.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :prolific_pid, :string
      add :prolific_session_id, :string
      add :prolific_study_id, :string
      add :group_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
