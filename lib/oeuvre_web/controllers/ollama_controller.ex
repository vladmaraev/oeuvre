defmodule OeuvreWeb.OllamaController do
  use OeuvreWeb, :controller
  alias Oeuvre.OllamaService
  alias Phoenix.PubSub
  require Logger

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
    result = loop("", true)
    Logger.debug("[OllamaController result] #{result}")
    PubSub.unsubscribe(Oeuvre.PubSub, signalling_id)
    json(conn, %{role: "assistant", content: result})
  end

  defp loop(string, empty) do
    receive do
      "" ->
        case empty do
          true ->
            loop(string, false)

          _ ->
            string
        end

      msg ->
        case String.contains?(msg, "<s />") do
          true -> loop(string <> " [apology] ", false)
          _ -> loop(string <> msg, false)
        end
    end
  end
end
