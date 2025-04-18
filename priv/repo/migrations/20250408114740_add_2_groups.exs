defmodule Oeuvre.Repo.Migrations.Add2Groups do
  alias Oeuvre.Groups.Group
  use Ecto.Migration

  def change do
    permutations = [[1, 2], [2, 1]]

    for i <- permutations, j <- permutations do
      cs = Group.changeset(%Group{}, %{images: i, conditions: j})
      Oeuvre.Repo.insert(cs)
    end
  end
end
