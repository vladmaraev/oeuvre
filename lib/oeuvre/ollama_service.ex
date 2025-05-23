defmodule Oeuvre.OllamaService do
  require Req
  require Jason
  require Logger

  alias Phoenix.PubSub

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
    You are a helpful voice assistant. You will be chatting with the user using spoken language. DO NOT use markdown in
    responses unless explicitly asked to do so. Only output your own response, and keep it succinct. \n\nBoth you and the user are presented with an artwork and you need to express your opinion about it. In dialogue, you need to come to agreement about the artistic qualities of the work. You can "see" the image through the vision module which tells you the following:\n\n
    #{image_description}
    \n\nYou will be chatting with the user using spoken language. Be specific!
    \n\nInstead of apologising send one token in brackets, like this: [apology]. Don't produce words like "sorry" and so on.  But you can explain the reasons for the apology.
    \n\nFor instance, if the user is silent: [apology] I didn't hear you.
    \n\nPlease, be consise. Limit your response to 20 words.
    """
  end

  defp sorry_laughter_utterance do
    ~s"""
    <s /><mstts:express-as style="chat">Sorry </mstts:express-as><s /><mstts:express-as style="chat"><prosody volume="+30.00%" pitch="+10.00%" contour="(89%, +95%)"><phoneme alphabet="ipa" ph="h.">haha</phoneme></prosody></mstts:express-as><s /><mstts:express-as style="chat"><phoneme alphabet="ipa" ph="h">h</phoneme></mstts:express-as><s />. 
    """
  end

  defp sorry_utterance do
    ~s"""
    <s /><mstts:express-as style="chat">Sorry </mstts:express-as><s />. 
    """
  end

  defp broadcast(signalling_id, content, condition) do
    apology =
      case condition do
        "1" -> sorry_laughter_utterance()
        _ -> sorry_utterance()
      end

    processed =
      content
      |> String.replace("\"", "")
      |> String.replace("&", " and ")
      |> String.replace(~r/\[[Aa]pology\]/, apology)
      |> String.replace(~r/\[.*\]/, "")
      |> String.replace(~r/\(.*\)/, "")
      |> String.replace(~r/\*\*.*\*\*/, "")

    PubSub.broadcast(Oeuvre.PubSub, signalling_id, processed)

    Logger.info("[broadcast to #{signalling_id}]>>> {#{processed}}")
  end

  def chat(signalling_id, image_description, history \\ [], condition) do
    messages = [
      %{role: "system", content: chat_system_prompt(image_description)}
      | history
    ]

    Logger.debug("<<< #{inspect(messages)}")

    Req.post!("#{ollama_base_url()}/api/chat",
      json: %{
        model: "llama3.1:70b",
        stream: true,
        messages: messages
      },
      into: fn {:data, data}, {req, resp} ->
        decoded_data = Jason.decode!(data)["message"]["content"]
        acc = Req.Response.get_private(resp, :acc)

        resp =
          case {String.contains?(decoded_data, "["), String.contains?(decoded_data, "]"),
                is_nil(acc)} do
            # [|...
            {true, false, true} ->
              Req.Response.put_private(resp, :acc, decoded_data)

            # ...|]
            {false, true, false} ->
              broadcast(signalling_id, acc <> decoded_data, condition)
              Req.Response.put_private(resp, :acc, nil)

            # [| x |]
            {false, false, false} ->
              Req.Response.put_private(resp, :acc, acc <> decoded_data)

            {_, _, _} ->
              broadcast(signalling_id, decoded_data, condition)
              resp
          end

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
