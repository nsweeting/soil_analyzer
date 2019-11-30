defmodule SoilAnalyzerWeb.PageController do
  use SoilAnalyzerWeb, :controller

  alias Phoenix.LiveView

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _) do
    LiveView.Controller.live_render(conn, SoilAnalyzerWeb.ProcessorLive)
  end
end
