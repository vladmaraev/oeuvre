defmodule Oeuvre.Repo.Migrations.AddGroups3 do
  use Ecto.Migration

  alias Oeuvre.Groups.Group

  def change do
    permutations = [[1, 2, 3, 4], [2, 3, 4, 1], [3, 4, 1, 2], [4, 1, 2, 3]]

    for i <- permutations, j <- permutations do
      cs = Group.changeset(%Group{}, %{images: i, conditions: j})
      Oeuvre.Repo.insert(cs)
    end
  end
end
