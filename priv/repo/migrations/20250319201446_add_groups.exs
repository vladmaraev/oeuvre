defmodule Oeuvre.Repo.Migrations.AddGroups do
  use Ecto.Migration

  alias Oeuvre.Group

  def change do
    permutations = [0x1234, 0x2341, 0x3421, 0x4123]

    for i <- permutations, j <- permutations do
      cs = Group.changeset(%Group{}, %{images: i, conditions: j})
      Oeuvre.Repo.insert(cs)
    end
  end
end
