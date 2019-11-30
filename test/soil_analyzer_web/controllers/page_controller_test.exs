defmodule SoilAnalyzerWeb.PageControllerTest do
  use SoilAnalyzerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Soil Analyzer"
  end
end
