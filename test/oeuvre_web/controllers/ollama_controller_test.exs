defmodule OeuvreWeb.OllamaControllerTest do
  use OeuvreWeb.ConnCase, async: true
  require Logger

  test "POST /ollama/chat", %{conn: conn} do
    conn =
      post(conn, ~p"/ollama/chat", %{
        "description" => "Beautiful flowers in a vase.",
        "history" => [
          %{role: "assistant", content: "Hello"},
          %{role: "user", content: "What do you think?"},
          %{
            "content" =>
              "(apology) I love the vibrant colors of the flowers and how they're arranged in the vase, it's a very classic and elegant still life composition.",
            "role" => "assistant"
          },
          %{role: "user", content: "So what?"},
          %{
            "content" =>
              "(laughs) The simplicity of the setup actually highlights the beauty of the flowers themselves, don't you think?",
            "role" => "assistant"
          },
          %{role: "user", content: "I don't agree!"},
          %{"content" => " (laughs)  Not my taste", "role" => "assistant"},
          %{role: "user", content: "[the user is not saying anything or you can't hear them]"}
        ],
        "signalling_id" => "test",
        "condition" => "1"
      })
    assistant_response = json_response(conn, 200)
    Logger.info(inspect(assistant_response))
    assert "assistant" =~ assistant_response["role"]
  end
end
