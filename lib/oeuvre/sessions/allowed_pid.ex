defmodule Oeuvre.Sessions.AllowedPid do
  use Ecto.Schema
  import Ecto.Changeset

  schema "allowed_pids" do
    field :prolific_pid, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(allowed_pid, attrs) do
    allowed_pid
    |> cast(attrs, [:prolific_pid])
    |> validate_required([:prolific_pid])
  end
end
