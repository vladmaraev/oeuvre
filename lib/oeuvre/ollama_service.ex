defmodule Oeuvre.OllamaService do
  require Req
  require Jason
  require Logger

  alias Phoenix.PubSub

  defp ollama_host, do: Application.fetch_env!(:oeuvre, Oeuvre.OllamaService)[:host]
  defp ollama_port, do: Application.fetch_env!(:oeuvre, Oeuvre.OllamaService)[:port]

  defp ollama_base_url do
    host = Application.fetch_env!(:oeuvre, Oeuvre.OllamaService)[:host]
    port = Application.fetch_env!(:oeuvre, Oeuvre.OllamaService)[:port]
    "http://#{host}:#{port}"
  end

  def get_image_base64(imgname) do
    {:ok, %{:status => status, :body => body}} =
      Req.get(
        "https://ttlfngopsrcdgjlvuitl.supabase.co/storage/v1/object/public/images/#{imgname}.jpg"
      )

    case status do
      200 -> {:ok, Base.encode64(body)}
      400 -> {:error, "Image not found"}
    end
  end

  defp visual_description_prompt do
    """
    Please provide a description which would be suitable for a
    human to assess the artistic quality of the image. Be as precise
    and specific as possible. Additionally, describe what is depicted on this image.
    """
  end

  defp chat_system_prompt(image_description) do
    """
    You are a helpful voice assistant. You will be chatting with the user using spoken language. Keep your response VERY brief. Please, answer with just one very short sentence!\n\nBoth you and the user are presented with an artwork and you need to express your opinion about it. In dialogue, you need to come to agreement about the artistic qualities of the work. You can "see" the image through the vision module which tells you the following:\n\n
    #{image_description}
    \n\nYou will be chatting with the user using spoken language. Keep your response VERY brief. Your response should always contain one very short sentence.
    \n\nIf the user is not responding say: Sorry, I didn't hear you.\n\nPlease, be consise. 
    """
  end

  def chat(image_description, history \\ []) do
    messages = [
      %{role: "system", content: chat_system_prompt(image_description)}
      | history
    ]

    Logger.debug("<<< #{inspect(messages)}")

    Req.post!("#{ollama_base_url()}/api/chat",
      json: %{
        model: "mistral",
        stream: true,
        messages: messages
      },
      into: fn {:data, data}, {req, resp} ->
        decoded_data = Jason.decode!(data)
        content = decoded_data["message"]["content"]
        PubSub.broadcast(Oeuvre.PubSub, "user:123", content)
        Logger.debug(">>> '#{content}'")
        {:cont, {req, resp}}
      end
    )
  end

  def ollama_generate_visual_description(image64) do
    Req.post!("#{ollama_base_url()}/api/generate",
      receive_timeout: 60_000,
      json: %{
        model: "llava:34b",
        stream: false,
        prompt: visual_description_prompt(),
        images: [image64]
      }
    ).body["response"]
  end
end
