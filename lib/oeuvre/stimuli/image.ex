defmodule Oeuvre.Stimuli.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :filename, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:filename])
    |> validate_required([:filename])
  end
end
