defmodule Oeuvre.Groups do
  import Ecto.Query, warn: false
  alias Oeuvre.Repo
  alias Oeuvre.Groups.Group

  require Logger

  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Returns next group to be assigned
  """
  def next_group do
    Repo.one(from g in Group, where: g.pointer == true)
  end

  def move_pointer do
    current_group = next_group()

    next =
      case Repo.one(from g in Group, where: g.id == ^current_group.id + 1) do
        nil ->
          Repo.one(from g in Group, where: g.id == 1)

        x ->
          x
      end

    Group.changeset(current_group, %{pointer: false}) |> Repo.update()
    Group.changeset(next, %{pointer: true}) |> Repo.update()
  end
end
