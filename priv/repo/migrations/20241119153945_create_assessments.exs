defmodule Oeuvre.Repo.Migrations.CreateAssessments do
  use Ecto.Migration

  def change do
    create table(:assessments) do
      add :image, :text
      add :q1, :text
      add :q2a, :text
      add :q2b, :text
      add :q2c, :text
      add :q2d, :text
      add :q2e, :text
      add :q2f, :text
      add :q3, :text
      add :q4, :text
      add :q5, :text
      add :trial_id, references(:trials, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:assessments, [:trial_id])
  end
end
