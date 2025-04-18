defmodule Oeuvre.Repo.Migrations.CreatePermittedPids do
  alias Oeuvre.Session.PermittedPids
  use Ecto.Migration

  def change do
    for i <- ["vlad_test"] do
      cs = PermittedPids.changeset(%PermittedPids{}, %{prolific_pid: i})
      Oeuvre.Repo.insert(cs)
    end
  end
end
