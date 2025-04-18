defmodule Oeuvre.Repo.Migrations.CreateTranscripts do
  use Ecto.Migration

  def change do
    create table(:transcripts) do
      add :session_id, :integer
      add :moves, {:array, :map}

      timestamps(type: :utc_datetime)
    end
  end
end
