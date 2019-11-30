defmodule SoilAnalyzer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  ##################################
  # Application callbacks
  ##################################

  @doc false
  @impl Application
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      SoilAnalyzerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SoilAnalyzer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc false
  @impl Application
  def config_change(changed, _new, removed) do
    SoilAnalyzerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
