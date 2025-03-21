defmodule Oeuvre.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :images, {:array, :integer}
    field :conditions, {:array, :integer}
    field :pointer, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:images, :conditions, :pointer])
    |> validate_required([:images, :conditions, :pointer])
  end
end
