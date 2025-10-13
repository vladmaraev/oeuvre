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
    |> sse_loop(signalling_id)
  end

  # https://code.krister.ee/server-sent-events-with-elixir/
  defp sse_loop(conn, signalling_id) do
    receive do
      {:plug_conn, :sent} ->
        sse_loop(conn, signalling_id)

      "" ->
        sse_loop(conn, signalling_id)

      "~~~DONE~~~" ->
        conn |> chunk("event: STREAMING_DONE\ndata: \n\n")
        conn

      msg ->
        conn |> chunk("event: STREAMING_CHUNK\ndata: #{msg}\n\n")
        sse_loop(conn, signalling_id)
    end
  end
end
