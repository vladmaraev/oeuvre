defmodule OeuvreWeb.Router do
  use OeuvreWeb, :router

  defp put_user_token(conn, _) do
    token = Phoenix.Token.sign(conn, "user socket", 1)
    assign(conn, :user_token, token)
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OeuvreWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_user_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :sse do
    plug :accepts, ["sse"]
    plug :put_format, "text/event-stream"
    plug :fetch_session
  end

  # pipeline :webrtc_recording do
  #   plug OeuvreWeb.WebRTCRecording
  # end

  scope "/", OeuvreWeb do
    pipe_through [:browser]

    get "/", SessionController, :new
  end

  scope "/", OeuvreWeb do
    pipe_through :browser

    resources "/images", ImageController
  end

  scope "/session", OeuvreWeb do
    pipe_through :api
    post "/savetranscript", SessionController, :save_transcript
    get "/completestep", SessionController, :complete_step
  end

  scope "/ollama", OeuvreWeb do
    pipe_through :api

    post "/describe", OllamaController, :describe_image
    post "/chat", OllamaController, :chat
  end

  scope "/azureToken", OeuvreWeb do
    pipe_through :api

    get "/", AzureController, :token
  end

  scope "/sse", OeuvreWeb do
    pipe_through :sse

    get "/", SseController, :subscribe
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:oeuvre, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OeuvreWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
