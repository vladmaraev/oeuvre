defmodule OeuvreWeb.SessionController do
  use OeuvreWeb, :controller
  require Logger

  alias Oeuvre.OllamaService
  alias Oeuvre.Groups
  alias Oeuvre.Sessions
  alias Oeuvre.Stimuli

  def get_image(group, step) do
    i = Enum.at(group.images, step)

    %{filename: filename} = Stimuli.get_image!(i)
    {:ok, image} = OllamaService.get_image_base64(filename)
    image
  end

  def new(conn, %{
        "prolific_pid" => prolific_pid,
        "session_id" => prolific_session_id,
        "study_id" => prolific_study_id
      }) do
    case Sessions.get_prolific_session(prolific_pid) do
      nil ->
        group = Groups.next_group()

        Sessions.create_session(%{
          prolific_pid: prolific_pid,
          prolific_session_id: prolific_session_id,
          prolific_study_id: prolific_study_id,
          group_id: group.id,
          step: 0
        })

        Groups.move_pointer()
        render(conn, :start, image: get_image(group, 0), condition: "")

      session ->
        group = Groups.get_group!(session.group_id)

        render(conn, :start, image: get_image(group, session.step), condition: "")
    end
  end

  def next_step(conn, %{
        "prolific_pid" => prolific_pid,
        "session_id" => prolific_session_id,
        "study_id" => prolific_study_id
      }) do
    case Sessions.get_prolific_session(prolific_pid) do
      nil ->
        raise Ecto.NoResultsError

      session ->
        Sessions.update_session(session, %{step: session.step + 1})

        redirect(conn,
          to:
            "/?prolific_pid=#{prolific_pid}&session_id=#{prolific_session_id}&study_id=#{prolific_study_id}"
        )
    end
  end
end
