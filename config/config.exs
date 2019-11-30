# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :soil_analyzer, SoilAnalyzerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "IjZre7hmJgfJeTRaoltODy9ojrTHTUty9bmUzZFQlRm/lXbVWv+N2GPmWAb9iHLN",
  render_errors: [view: SoilAnalyzerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SoilAnalyzer.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "OYJKyO0hgmlxfp06+E3cn6kBkZKt3Noc"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
