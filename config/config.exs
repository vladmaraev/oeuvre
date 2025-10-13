# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :oeuvre,
  ecto_repos: [Oeuvre.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :oeuvre, OeuvreWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: OeuvreWeb.ErrorHTML, json: OeuvreWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Oeuvre.PubSub,
  live_view: [signing_salt: "6Y1cRqX+"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :oeuvre, Oeuvre.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  oeuvre: [
    args:
      ~w(./js/app --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  oeuvre: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :mime, :types, %{
  "text/event-stream" => ["sse"]
}

# config :bundlex, :disable_precompiled_os_deps, apps: [:ex_libsrtp, :membrane_aac_fdk_plugin, :membrane_opus_plugin, :membrane_mp3_mad_plugin, :membrane_vpx_plugin, :membrane_transcoder_plugin]

config :bundlex, :disable_precompiled_os_deps,
  apps: [:membrane_vpx_plugin, :membrane_rtp_vp8_plugin, :ex_libsrtp, :ex_libsrt]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
