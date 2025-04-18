defmodule Oeuvre.Repo.Migrations.CreateTrials do
  use Ecto.Migration

  def change do
    create table(:trials) do
      add :trial, :string

      timestamps(type: :utc_datetime)
    end
  end
end
