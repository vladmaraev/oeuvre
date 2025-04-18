defmodule OeuvreWeb.SessionController do
  use OeuvreWeb, :controller
  require Logger

  alias OeuvreWeb.OeuvreWeb.UnauthorisedError
  alias Oeuvre.OllamaService
  alias Oeuvre.Groups
  alias Oeuvre.Sessions
  alias Oeuvre.Stimuli

  alias Membrane.WebRTC.PhoenixSignaling

  defp recordings_path,
    do: Application.fetch_env!(:oeuvre, OeuvreWeb.SessionController)[:recordings_path]

  defp get_image(group, step) do
    i = Enum.at(group.images, step)

    %{filename: filename} = Stimuli.get_image!(i)
    {:ok, image} = OllamaService.get_image_base64(filename)
    image
  end

  def get_condition(group, step) do
    Enum.at(group.conditions, step)
  end

  defp authorised?(pid) do
    pid in (Sessions.list_allowed_pids() |> Enum.map(fn x -> x.prolific_pid end))
  end

  defp qualtrics_final_redirect(conn, prolific_pid) do
    redirect(conn,
      external:
        "https://samgu.eu.qualtrics.com/jfe/form/SV_3f0mHKnrQPkx8kC?prolific_pid=#{prolific_pid}"
    )
  end

  def new(conn, %{
        "prolific_pid" => prolific_pid,
        "session_id" => prolific_session_id,
        "study_id" => prolific_study_id
      }) do
    case Sessions.get_prolific_session(prolific_pid) do
      nil ->
        if not authorised?(prolific_pid) do
          raise UnauthorisedError, "access denied"
        end

        group = Groups.next_group()

        Sessions.create_session(%{
          prolific_pid: prolific_pid,
          prolific_session_id: prolific_session_id,
          prolific_study_id: prolific_study_id,
          group_id: group.id,
          step: 0
        })

        Groups.move_pointer()

        new(conn, %{
          "prolific_pid" => prolific_pid,
          "session_id" => prolific_session_id,
          "study_id" => prolific_study_id
        })

      session ->
        case session.step do
          -1 ->
            qualtrics_final_redirect(conn, prolific_pid)

          _ ->
            group = Groups.get_group!(session.group_id)
            image = get_image(group, session.step)
            condition = get_condition(group, session.step)

            # description = OllamaService.ollama_generate_visual_description(image)
            # description = "dummy description"

            unique_id = UUID.uuid4()

            Task.start(fn ->
              input_sg = PhoenixSignaling.new("#{unique_id}_egress_screen")

              Boombox.run(
                input: {:webrtc, input_sg},
                output: {:mp4, "#{recordings_path()}/x_screen_#{prolific_pid}_#{unique_id}.mp4"}
              )
            end)

            Task.start(fn ->
              input_sg = PhoenixSignaling.new("#{unique_id}_egress_mic")

              Boombox.run(
                input: {:webrtc, input_sg},
                output: {:mp4, "#{recordings_path()}/x_mic_#{prolific_pid}_#{unique_id}.mp4"}
              )
            end)

            render(conn, :start,
              # description: description,
              signalling_id: unique_id,
              image: image,
              session_id: session.id,
              step: session.step,
              prolific_pid: prolific_pid,
              condition: condition
            )
        end
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
        group = Groups.get_group!(session.group_id)

        if session.step == length(group.conditions) - 1 do
          Sessions.update_session(session, %{step: -1})
          qualtrics_final_redirect(conn, prolific_pid)
        else
          Sessions.update_session(session, %{step: session.step + 1})

          new(conn, %{
            "prolific_pid" => prolific_pid,
            "session_id" => prolific_session_id,
            "study_id" => prolific_study_id
          })
        end
    end
  end

  def save_transcript(conn, %{
        "session_id" => session_id,
        "moves" => moves,
        "step" => step
      }) do
    case Sessions.create_transcript(%{
           session_id: session_id,
           moves: moves,
           step: step
         }) do
      {:ok, _} -> json(conn, %{status: "success"})
    end
  end
end
