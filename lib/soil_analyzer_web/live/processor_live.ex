defmodule SoilAnalyzerWeb.ProcessorLive do
  use Phoenix.LiveView

  alias SoilAnalyzer.Request
  alias SoilAnalyzer.Processors.WaterConcentration

  @doc false
  @impl Phoenix.LiveView
  def render(assigns) do
    SoilAnalyzerWeb.PageView.render("index.html", assigns)
  end

  @doc false
  @impl Phoenix.LiveView
  def mount(_session, socket) do
    {:ok, assign(socket, input: nil, request: nil, errors: nil, loading: false)}
  end

  @doc false
  @impl Phoenix.LiveView
  def handle_event(
        "run",
        %{"processor" => "water_concentration", "input" => input},
        socket
      ) do
    send(self(), {:run, WaterConcentration, input})
    socket = assign(socket, input: input, request: nil, errors: nil, loading: true)
    {:noreply, socket}
  end

  def handle_event("run", %{"processor" => processor}, socket) do
    errors = ["#{processor} is an invalid processor"]
    socket = assign(socket, input: nil, request: nil, errors: errors, loading: false)
    {:noreply, socket}
  end

  @doc false
  @impl Phoenix.LiveView
  def handle_info({:run, processor, input}, socket) do
    case processor.run(input) do
      %Request{valid?: true} = request ->
        {:noreply, assign(socket, request: request, loading: false)}

      request ->
        {:noreply, assign(socket, request: nil, errors: request.errors, loading: false)}
    end
  end
end
