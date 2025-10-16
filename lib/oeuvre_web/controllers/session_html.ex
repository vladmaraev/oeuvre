defmodule OeuvreWeb.SessionHTML do
  use OeuvreWeb, :live_view

  embed_templates "session_html/*"

  attr :condition, :string

  def avatar(assigns) do
    ~H"""
    <div class="flex p-4">
      <button
        id="speechstate"
        phx-hook="SpeechState"
        class="bg-neutral-100 text-slate-900 text-2xl text-center px-5 rounded-r-2xl flex flex-row h-32 w-64 items-center justify-start gap-4 border border-[2px] border-slate-900"
      >
        <img class="h-20 shrink-0" src={"images/dude#{@condition}.svg"} />
      </button>
    </div>
    """
  end

  attr :image64, :string

  def image(assigns) do
    ~H"""
    <div class="flex-1 min-h-0" id="image">
      <img
        class="max-w-full max-h-full object-contain mx-auto mb-10"
        src={"data:image/jpeg;base64, #{@image64}"}
      />
    </div>
    """
  end

  def instruction(assigns) do
    ~H"""
    <section class="m-5 p-5 rounded-md bg-lime-100 h-full" id="modal" hidden>
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
          <li><span class="me-2">🎧</span> Ideally, use a headset.</li>
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

  def consent_form(assigns) do
    ~H"""
    <section class="m-5 p-5 rounded-md bg-slate-100 h-full" id="consent_form">
      <h1 class="text-2xl font-semibold mb-5" id="instructions">
        Consent form
      </h1>
      <article id="meat" class="text-xl">
        <p class="mb-3">
          In this task, you will be asked to have a spoken discussion with an AI about the given work of art. After the discussion you will be asked to fill in two short surveys.
        </p>
        <p class="mb-3">
          By clicking the "<strong>Yes, I consent.</strong>" button below, you acknowledge:
        </p>
        <ol class="list-disc pl-4 mb-5 *:py-1 *:me-2 ml-5">
          <li>You are at least 18 years of age.</li>
          <li>You are a fluent English speaker.</li>
          <li>Your participation in the study is voluntary.</li>
          <li>You are aware that we will be recording your voice.</li>
          <li>
            You are aware that your voice will be automatically transcribed using Microsoft Azure AI services.
            <a href="https://learn.microsoft.com/en-us/legal/cognitive-services/speech-service/speech-to-text/data-privacy-security?context=%2Fazure%2Fai-services%2Fspeech-service%2Fcontext%2Fcontext#no-data-trace">
              Microsoft does not retain or store the data provided by customers.
            </a>
          </li>
          <li>
            You are aware that transcripts and recordings from the conversations will be made available to the research community and stored for future research purposes.
          </li>
          <li>
            You are aware that you may choose to terminate your participation at any time for any reason.
          </li>
          <li>You are aware that you may contact us to withdraw your consent and your data.</li>
          <li>
            You are aware that the results of the study may be published in a journal/conference, with anonymized data, and no information can reveal your identity.
          </li>
          <li>
            You are required to use <strong>Google Chrome or other Chromium-based browser</strong>
            for the study.
          </li>
        </ol>
        <button
          id="consentclose"
          class="bg-slate-300 text-slate-900 py-2 px-5 rounded font-semibold hover:bg-amber-200 hover:border-lime-200"
        >
          Yes, I consent.
        </button>
        <p class="mt-3 pl-4 text-sm font-semibold text-red-600">
          If you do not wish to participate in this study, please close this page and return your submission on Prolific by selecting the “Stop without completing” button.
        </p>
      </article>
    </section>
    """
  end

  attr :prolific_pid, :string

  def survey(assigns) do
    ~H"""
    <div id="survey" class="w-full h-screen" hidden>
      <iframe
        src={"https://samgu.eu.qualtrics.com/jfe/form/SV_dmwElLOHB3KX4x0?prolific_pid=#{@prolific_pid}"}
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

      document.getElementById("consentclose").addEventListener("click", () =>  {
          document.getElementById('modal').hidden = false;
          document.getElementById('consent_form').hidden = true; 
        })
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
