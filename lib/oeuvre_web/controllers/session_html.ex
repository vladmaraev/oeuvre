defmodule OeuvreWeb.SessionHTML do
  use OeuvreWeb, :live_view

  embed_templates "session_html/*"

  attr :condition, :string

  def avatar(assigns) do
    ~H"""
    <div class="flex justify-center mb-10">
      <button
        id="speechstate"
        phx-hook="SpeechState"
        class="bg-neutral-100 text-slate-900 text-2xl text-center py-2 px-5 rounded-r-2xl flex flex-row h-40 w-64 items-center justify-start gap-4 border border-[2px] border-slate-900"
      >
        <img class="h-20 shrink-0" src={"images/dude#{@condition}.svg"} />
      </button>
    </div>
    """
  end

  attr :image64, :string

  def image(assigns) do
    ~H"""
    <div class="w-full" id="image" hidden>
      <img class="mx-auto" src={"data:image/jpeg;base64, #{@image64}"} />
    </div>
    """
  end

  def instruction(assigns) do
    ~H"""
    <section class="m-5 p-5 rounded-md bg-lime-100 h-full" id="modal">
      <h1 class="text-2xl font-semibold mb-5" id="instructions">
        🖼️ Welcome to the exploration of Art & AI! 🤖
      </h1>
      <article id="meat" class="text-xl">
        <p class="mb-3">Please, follow the instructions:</p>
        <ol class="list-none pl-4 mb-5 *:py-1">
          <li><span class="me-2">🗣️</span> Talk to AI using your voice, have a discussion!</li>
          <li>
            <span class="me-2">❓</span>
            After the discussion you will need to answer a few questions about the work of art.
          </li>
          <li>
            <span class="me-2">🎤</span>
            You will be asked to share your microphone and this tab of your browser.
          </li>
          <li><span class="me-2">🤫</span> Make sure you are sitting in a quiet environment.</li>
          <li><span class="me-2">🎧</span> Ideally, a headset.</li>
        </ol>

        <p class="pl-4 text-sm font-semibold">Ideas to discuss</p>
        <ol class="list-numbered pl-4 *:py-0 text-sm">
          <li>Is it very innovative? Beautiful? Thought-provoking?</li>
          <li>Does it evoke emotions? Memories?</li>
          <li>What does it depict? Do you understand it? Is it unique?</li>
        </ol>
        <button
          id="modalclose"
          class="mt-7 bg-slate-300 text-slate-900 py-2 px-5 rounded font-semibold hover:bg-amber-200 hover:border-lime-200"
        >
          I understood the instructions. Let’s start!
        </button>
      </article>
    </section>
    """
  end

  attr :prolific_pid, :string

  def survey(assigns) do
    ~H"""
    <div id="survey" class="w-full h-screen" hidden>
      <iframe
        src="https://samgu.eu.qualtrics.com/jfe/form/SV_dmwElLOHB3KX4x0?prolific_pid=#{@prolific_pid}"
        width="100%"
        height="100%"
      >
      </iframe>
    </div>
    """
  end

  attr :image64, :string
  attr :session_id, :integer
  attr :step, :integer
  attr :prolific_pid, :string
  attr :condition, :string

  def script(assigns) do
    ~H"""
    <script type="module">
        if (!window.chrome) {
            document.getElementById("instructions").innerText = "You must use Google Chrome browser."
            document.getElementById("meat").hidden = true
        } else {
          
      const param = {
          image64: `<%= @image64 %>`,
          session_id: <%= @session_id %>,
          step: <%= @step %>,
            prolific_pid: `<%= @prolific_pid %>`,
              condition: `<%= @condition %>`

      }

      document.getElementById('modalclose').addEventListener("click", () =>  {
      document.getElementById('modal').hidden = true;
      document.getElementById('container').hidden = false; 
      window.startSpeechState(param);
      })
        }
    </script>
    """
  end

  def is_chrome?(assigns) do
    ~H"""
    <script type="module">
        if (!window.chrome) {
          document.getElementById("instructions").innerText = "You must use Google Chrome browser."
          document.getElementById("meat").hidden = true
      }
    </script>
    """
  end
end
