defmodule OeuvreWeb.SseController do
  use OeuvreWeb, :controller
  alias Phoenix.PubSub
  require Logger

  def subscribe(conn, _params) do
    PubSub.subscribe(Oeuvre.PubSub, "user:123")
    Logger.debug("Subscribed to #{Oeuvre.PubSub}")

    conn
    |> put_resp_content_type("text/event-stream")
    |> put_resp_header("cache-control", "no-cache")
    |> send_chunked(200)
    |> sse_loop()
  end

  # https://code.krister.ee/server-sent-events-with-elixir/
  defp sse_loop(conn) do
    receive do
      {:plug_conn, :sent} ->
        sse_loop(conn)

      "" ->
        PubSub.unsubscribe(Oeuvre.PubSub, "user:123")
        conn |> chunk("event: STREAMING_DONE\ndata: \n\n")
        conn

      msg ->
        conn |> chunk("event: STREAMING_CHUNK\ndata: #{msg}\n\n")
        sse_loop(conn)
    end
  end
end
