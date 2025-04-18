defmodule Oeuvre.Repo.Migrations.TranscriptsAddStepsColumn do
  use Ecto.Migration

  def change do
    alter table(:transcripts) do
      add :step, :integer
    end
  end
end
