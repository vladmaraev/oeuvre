defmodule Oeuvre.Sessions.Transcript do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transcripts" do
    field :moves, {:array, :map}
    field :session_id, :integer
    field :step, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transcript, attrs) do
    transcript
    |> cast(attrs, [:session_id, :moves, :step])
    |> validate_required([:session_id, :moves, :step])
  end
end
