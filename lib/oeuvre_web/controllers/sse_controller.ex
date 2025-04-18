defmodule OeuvreWeb.SseController do
  use OeuvreWeb, :controller
  alias Phoenix.PubSub
  require Logger

  def subscribe(conn, %{"signalling_id" => signalling_id}) do
    PubSub.subscribe(Oeuvre.PubSub, signalling_id)
    Logger.debug("Subscribed to #{Oeuvre.PubSub} session_id: #{signalling_id}")

    conn
    |> put_resp_content_type("text/event-stream")
    |> put_resp_header("cache-control", "no-cache")
    |> send_chunked(200)
    |> sse_loop(signalling_id, true)
  end

  # https://code.krister.ee/server-sent-events-with-elixir/
  defp sse_loop(conn, signalling_id, empty) do
    receive do
      {:plug_conn, :sent} ->
        sse_loop(conn, signalling_id, true)

      "" ->
        if empty do
          sse_loop(conn, signalling_id, false)
        else
          PubSub.unsubscribe(Oeuvre.PubSub, signalling_id)
          conn |> chunk("event: STREAMING_DONE\ndata: \n\n")
          conn
        end

      msg ->
        conn |> chunk("event: STREAMING_CHUNK\ndata: #{msg}\n\n")
        sse_loop(conn, signalling_id, false)
    end
  end
end
