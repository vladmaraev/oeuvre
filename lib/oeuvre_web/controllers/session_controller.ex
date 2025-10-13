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

  def authorised?(pid, study_id) do
    # pid in (Sessions.list_allowed_pids() |> Enum.map(fn x -> x.prolific_pid end))
    study_id == "0umqymnnc1l"
  end

  defp qualtrics_final_redirect(conn, prolific_pid, prolific_session_id, prolific_study_id) do
    redirect(conn,
      external:
        "https://samgu.eu.qualtrics.com/jfe/form/SV_3f0mHKnrQPkx8kC?prolific_pid=#{prolific_pid}&prolific_session_id=#{prolific_session_id}&prolific_study_id=#{prolific_study_id}"
    )
  end

  defp qualtrics_redirect(conn, prolific_pid, prolific_session_id, prolific_study_id, step) do
    redirect(conn,
      external:
        "https://samgu.eu.qualtrics.com/jfe/form/SV_dmwElLOHB3KX4x0?prolific_pid=#{prolific_pid}&prolific_session_id=#{prolific_session_id}&prolific_study_id=#{prolific_study_id}&step=#{step}"
    )
  end

  defp kvtuple_to_string({key, value}) do
    to_string(key) <> "=" <> to_string(value)
  end

  defp map_to_url_attributes(m) do
    Map.to_list(m)
    |> Enum.map(&kvtuple_to_string/1)
    |> Enum.join("&")
  end

  defp formbricks_redirect(conn, attrs) do
    redirect(conn,
      external:
        "https://dev.clasp.gu.se:8020/s/cmdcvog990000mq01yiaa8kvu?#{map_to_url_attributes(attrs)}"
    )
  end

  defp formbricks_final_redirect(conn, attrs) do
    redirect(conn,
      external:
        "https://dev.clasp.gu.se:8020/s/cmdem3kka0001mq01z122viwr?#{map_to_url_attributes(attrs)}"
    )
  end

  defp render_session(conn, session) do
    Logger.info(inspect({session.step, session.step_complete}))

    case {session.step, session.step_complete} do
      {1, true} ->
        Sessions.update_session(session, %{step: -1})

        formbricks_redirect(
          conn,
          %{
            session_id: session.id,
            prolific_pid: session.prolific_pid,
            prolific_session_id: session.prolific_session_id,
            prolific_study_id: session.prolific_study_id,
            step: session.step
          }
        )

      {0, true} ->
        Sessions.update_session(session, %{step: 1, step_complete: false})

        formbricks_redirect(
          conn,
          %{
            session_id: session.id,
            prolific_pid: session.prolific_pid,
            prolific_session_id: session.prolific_session_id,
            prolific_study_id: session.prolific_study_id,
            step: session.step
          }
        )

      {-1, _} ->
        formbricks_final_redirect(
          conn,
          %{
            session_id: session.id,
            prolific_pid: session.prolific_pid,
            prolific_session_id: session.prolific_session_id,
            prolific_study_id: session.prolific_study_id
          }
        )

      _ ->
        group = Groups.get_group!(session.group_id)
        image = get_image(group, session.step)
        condition = get_condition(group, session.step)

        # description = OllamaService.ollama_generate_visual_description(image)
        # description = "dummy description"

        unique_id = UUID.uuid4()

        # {:ok, _sup, _pid} =
        #   Membrane.Pipeline.start_link(Oeuvre.RecordingPipeline, %{
        #     screen_signaling_id: "#{unique_id}_egress_screen",
        #     mic_signaling_id: "#{unique_id}_egress_mic",
        #     out_path:
        #       Path.join(
        #         recordings_path(),
        #         "x_merged_#{session.prolific_pid}_#{unique_id}.mp4"
        #       )
        #   })

        Task.start(fn ->
          input_sg = PhoenixSignaling.new("#{unique_id}_egress_screen")

          Boombox.run(
            input: {:webrtc, input_sg},
            output:
              {:mp4, "#{recordings_path()}/x_screen_#{session.prolific_pid}_#{unique_id}.mp4"}
          )
        end)

        Task.start(fn ->
          input_sg = PhoenixSignaling.new("#{unique_id}_egress_mic")

          Boombox.run(
            input: {:webrtc, input_sg},
            output: {:mp4, "#{recordings_path()}/x_mic_#{session.prolific_pid}_#{unique_id}.mp4"}
          )
        end)

        render(conn, :start,
          # description: description,
          signalling_id: unique_id,
          image: image,
          session_id: session.id,
          step: session.step,
          prolific_pid: session.prolific_pid,
          condition: condition
        )
    end
  end

  def continue(conn, %{"session_id" => id}) do
    case Sessions.get_session!(id) do
      %{
        id: id,
        prolific_pid: prolific_pid,
        prolific_session_id: prolific_session_id,
        prolific_study_id: "0umqymnnc1l"
      } ->
        formbricks_final_redirect(
          conn,
          %{
            session_id: id,
            prolific_pid: prolific_pid,
            prolific_session_id: prolific_session_id,
            prolific_study_id: "0umqymnnc1l"
          }
        )

      session ->
        render_session(conn, session)
    end
  end

  def new(conn, %{
        "prolific_pid" => prolific_pid,
        "session_id" => prolific_session_id,
        "study_id" => prolific_study_id
      }) do
    case Sessions.get_prolific_session(prolific_pid) do
      nil ->
        if not authorised?(prolific_pid, prolific_study_id) do
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
        render_session(conn, session)
    end
  end

  def complete_step(conn, %{
        "prolific_pid" => prolific_pid
      }) do
    case Sessions.get_prolific_session(prolific_pid) do
      nil ->
        raise Ecto.NoResultsError

      session ->
        Sessions.update_session(session, %{step_complete: true})
        json(conn, %{status: "success"})
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
