defmodule OeuvreWeb.OllamaController do
  use OeuvreWeb, :controller
  alias Oeuvre.OllamaService
  alias Phoenix.PubSub
  require Logger

  def warmup(conn) do
    descr =
      OllamaService.ollama_generate_visual_description(
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
      )

    Logger.info(descr)

    OllamaService.chat(
      "test",
      descr,
      [%{role: "assistant", content: "Hello"}, %{role: "user", content: "What do you think?"}],
      "1"
    )

    json(conn, %{role: "assistant", content: ""})
  end

  def describe_image(conn, %{"image" => image}) do
    # The home page is often custom made,
    # so skip the default app layout.
    descr = OllamaService.ollama_generate_visual_description(image)
    json(conn, %{:description => descr})
  end

  def chat(
        conn,
        %{
          "description" => description,
          "history" => history,
          "signalling_id" => signalling_id,
          "condition" => condition
        }
      ) do
    PubSub.subscribe(Oeuvre.PubSub, signalling_id)
    OllamaService.chat(signalling_id, description, history, condition)
    result = loop("")
    Logger.info("[OllamaController result] #{result}")
    PubSub.unsubscribe(Oeuvre.PubSub, signalling_id)
    json(conn, %{role: "assistant", content: result})
  end

  defp loop(string) do
    receive do
      "~~~DONE~~~" ->
        string

      msg ->
        case String.contains?(msg, "<s />") do
          true -> loop(string <> " [apology] ")
          _ -> loop(string <> msg)
        end
    end
  end
end
