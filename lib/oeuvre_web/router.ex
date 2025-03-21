defmodule OeuvreWeb.Router do
  use OeuvreWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OeuvreWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :sse do
    plug :accepts, ["sse"]
    plug :put_format, "text/event-stream"
    plug :fetch_session
  end

  scope "/", OeuvreWeb do
    pipe_through :browser

    get "/", SessionController, :new

    resources "/trials", TrialController, except: [:delete, :index, :edit]
    resources "/a", AssessmentController, except: [:delete, :index, :edit]
    resources "/images", ImageController
  end

  scope "/session", OeuvreWeb do
    pipe_through :api
    get "/nextstep", SessionController, :next_step
  end
    
  scope "/ollama", OeuvreWeb do
    pipe_through :api

    get "/describe", OllamaController, :describe_image
    post "/chat", OllamaController, :chat
  end

  scope "/azureToken", OeuvreWeb do
    pipe_through :api

    get "/", AzureController, :token
  end

  scope "/demo", OeuvreWeb do
    pipe_through :browser

    get "/", DemoController, :demo
  end

  scope "/demo-live", OeuvreWeb do
    pipe_through :browser

    get "/", DemoController, :show
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
