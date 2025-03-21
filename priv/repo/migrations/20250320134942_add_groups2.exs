defmodule Oeuvre.Repo.Migrations.AddGroups2 do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :images, {:array, :integer}
      add :conditions, {:array, :integer}
      add :pointer, :boolean, default: false

      timestamps(type: :utc_datetime)
    end
  end
end
