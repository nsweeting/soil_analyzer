defmodule SoilAnalyzerWeb.ProcessorLiveTest do
  use SoilAnalyzerWeb.ConnCase

  import Phoenix.LiveViewTest

  alias SoilAnalyzer.Processors.WaterConcentration

  test "running a processor will set the input as read only" do
    conn = build_conn()
    {:ok, view, _html} = live(conn, "/")
    params = %{processor: "water_concentration", input: "1 1 1"}

    assert render_submit(view, :run, params) =~ "readonly=\"readonly\""
  end

  test "will return the expected output" do
    conn = build_conn()
    {:ok, view, _html} = live(conn, "/")
    send(view.pid, {:run, WaterConcentration, "1 1 1"})
    assert render(view) =~ "(0, 0 score: 1)"
  end
end
