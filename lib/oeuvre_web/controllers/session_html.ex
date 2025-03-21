defmodule OeuvreWeb.SessionHTML do
  use OeuvreWeb, :live_view

  embed_templates "session_html/*"
  attr :image64, :string
  attr :description, :string

  def avatar(assigns) do
    ~H"""
    <div class="flex justify-center mb-5">
      <button id="speechstate" class="btn-idle" phx-hook="SpeechState"></button>
    </div>
    """
  end

  def image(assigns) do
    ~H"""
    <div class="flex justify-center mb-5">
      <img src={"data:image/jpeg;base64, #{@image64}"} />
    </div>
    """
  end

  def script(assigns) do
    ~H"""
    <script type="module">
      window.dmActor.start();
      window.dmActor.send({type: "SETUP", value: `<%= @description %>`})
      window.addEventListener("message", (e) => {
        if (e.data === 'SURVEY_NEXT') {
           window.dmActor.send({type: "SURVEY_NEXT"})
      }});
    </script>
    """
  end
end
