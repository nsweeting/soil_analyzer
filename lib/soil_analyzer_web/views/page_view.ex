defmodule SoilAnalyzerWeb.PageView do
  use SoilAnalyzerWeb, :view

  @spec get_colour(SoilAnalyzer.Request.t(), integer(), integer()) :: binary()
  def get_colour(request, x, y) do
    request
    |> get_score(x, y)
    |> colour_from_score()
  end

  @spec get_score(SoilAnalyzer.Request.t(), integer(), integer()) :: integer()
  def get_score(request, x, y) do
    Map.get(request.assigns.scores, {x, y})
  end

  defp colour_from_score(score) when score > 80, do: "#2b82bc"
  defp colour_from_score(score) when score <= 80 and score > 70, do: "#3d9ecf"
  defp colour_from_score(score) when score <= 70 and score > 60, do: "#52b6e3"
  defp colour_from_score(score) when score <= 60 and score > 50, do: "#74d7f9"
  defp colour_from_score(score) when score <= 50 and score > 40, do: "#9ae3fd"
  defp colour_from_score(score) when score <= 40 and score > 30, do: "#afe9fd"
  defp colour_from_score(score) when score <= 30 and score > 20, do: "#cff0fe"
  defp colour_from_score(score) when score <= 20 and score > 10, do: "#dff7ff"
  defp colour_from_score(score) when score <= 10, do: "#f2fcfe"
end
