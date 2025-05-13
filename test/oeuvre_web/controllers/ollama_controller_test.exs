defmodule OeuvreWeb.OllamaControllerTest do
  use OeuvreWeb.ConnCase
  require Logger

  test "POST /ollama/chat", %{conn: conn} do
    conn =
      post(conn, ~p"/ollama/chat", %{
        "description" => "dummy description",
        "history" => [%{role: "assistant", content: ""}, %{role: "user", content: "Keep silent."}],
        "signalling_id" => "test",
        "condition" => "1"
      })

    assistant_response = json_response(conn, 200)
    Logger.info(inspect(assistant_response))
    assert "assistant" =~ assistant_response["role"]
  end
end
