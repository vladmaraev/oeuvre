defmodule Oeuvre.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :filename, :text

      timestamps(type: :utc_datetime)
    end
  end
end
