defmodule Oeuvre.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :prolific_pid, :string
    field :prolific_session_id, :string
    field :prolific_study_id, :string
    field :group_id, :integer
    field :step, :integer
    field :step_complete, :boolean

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [
      :prolific_pid,
      :prolific_session_id,
      :prolific_study_id,
      :group_id,
      :step,
      :step_complete
    ])
    |> validate_required([
      :prolific_pid,
      :prolific_session_id,
      :prolific_study_id,
      :group_id,
      :step
    ])
  end
end
