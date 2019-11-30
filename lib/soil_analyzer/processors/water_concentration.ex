defmodule SoilAnalyzer.Processors.WaterConcentration do
  @moduledoc """
  A soil analysis processor that finds areas of concentrated water.

  The input provided will be in the form of a string containing a list of numbers
  in the form: `"*t n Grid*"`. Where *t* is the number of results requested, *n*
  is the size of the grid and *grid* is a space delimited list of numbers that
  form the grid, starting with row 0.

  This data will be processed to find concentrated areas of water presence. The
  analysis consists of generating a score for each location on the grid. The score
  is determined by adding the location's own raw water concentration value to its
  surrounding raw values.

  ## Example

      iex> input = "1 5 5 3 1 2 0 4 1 1 3 2 2 3 2 4 3 0 2 3 3 2 1 0 2 4 3"
      iex> request = SoilAnalyzer.Processors.WaterConcentration.run(input)
      iex> request.output
      [{{3, 3}, [score: 26]}]

  """

  @behaviour SoilAnalyzer.Processor

  alias SoilAnalyzer.Request

  ##################################
  # SoilAnalyzer.Processor Callbacks
  ##################################

  @impl SoilAnalyzer.Processor
  @spec run(SoilAnalyzer.Processor.input()) :: SoilAnalyzer.Processor.output()
  def run(input) do
    request = Request.new(__MODULE__, input)

    with {:ok, request} <- validate(:input, request),
         {:ok, request} <- validate(:parsed_input, request),
         {:ok, request} <- validate(:results_requested, request),
         {:ok, request} <- validate(:grid_size, request),
         {:ok, request} <- validate(:raw_grid, request),
         {:ok, request} <- validate(:raw_grid_size, request) do
      request
      |> build_grids()
      |> calculate_scores()
      |> build_output()
    end
  end

  ##################################
  # Private API
  ##################################

  defp validate(:input, %Request{input: input} = request) when is_binary(input) do
    {:ok, request}
  end

  defp validate(:input, request) do
    Request.add_error(request, "input must be a string")
  end

  defp validate(:parsed_input, request) do
    request.input
    |> String.split()
    |> case do
      [_, _ | grid] = parsed_input when grid != [] ->
        {:ok, Request.assign(request, :parsed_input, parsed_input)}

      _ ->
        Request.add_error(request, "input must be in format 't n *grid'")
    end
  end

  defp validate(:results_requested, request) do
    [results_requested | _] = request.assigns.parsed_input

    with {:ok, results_requested} <- validate_integer(request, results_requested) do
      {:ok, Request.assign(request, :results_requested, results_requested)}
    end
  end

  defp validate(:grid_size, request) do
    [_, grid_size | _] = request.assigns.parsed_input

    with {:ok, grid_size} <- validate_integer(request, grid_size) do
      if grid_size <= 0 do
        Request.add_error(request, "grid size must be greater than 0")
      else
        {:ok, Request.assign(request, :grid_size, grid_size)}
      end
    end
  end

  defp validate(:raw_grid, request) do
    [_, _ | raw_grid] = request.assigns.parsed_input

    raw_grid
    |> Enum.reduce_while([], fn grid_value, new_grid ->
      case Integer.parse(grid_value) do
        {grid_value, ""} when grid_value > 9 ->
          {:halt, {:error, "#{grid_value} is too high of a measurement - must be less than 10"}}

        {grid_value, ""} ->
          {:cont, new_grid ++ [grid_value]}

        _ ->
          {:halt, {:error, "#{grid_value} is an invalid grid value"}}
      end
    end)
    |> case do
      {:error, error} -> Request.add_error(request, error)
      raw_grid -> {:ok, Request.assign(request, :raw_grid, raw_grid)}
    end
  end

  defp validate(:raw_grid_size, request) do
    grid_size = request.assigns.grid_size
    raw_grid_size = length(request.assigns.raw_grid)

    if rem(raw_grid_size, grid_size) == 0 do
      {:ok, request}
    else
      Request.add_error(request, "grid size does not match grid")
    end
  end

  defp validate_integer(request, value) do
    case Integer.parse(value) do
      {value, ""} -> {:ok, value}
      _ -> Request.add_error(request, "#{value} must be an integer")
    end
  end

  defp build_grids(request) do
    {grid, sorted_grid} =
      build_grid(%{}, [], request.assigns.raw_grid, request.assigns.grid_size - 1, {0, 0})

    sorted_grid = Enum.chunk_every(sorted_grid, request.assigns.grid_size)

    request
    |> Request.assign(:grid, grid)
    |> Request.assign(:sorted_grid, sorted_grid)
  end

  defp build_grid(grid, sorted_grid, [], _, _), do: {grid, sorted_grid}

  defp build_grid(grid, sorted_grid, raw_grid, grid_size, {x, y}) when x > grid_size do
    build_grid(grid, sorted_grid, raw_grid, grid_size, {0, y + 1})
  end

  defp build_grid(grid, sorted_grid, [grid_value | raw_grid], grid_size, {x, y}) do
    grid = Map.put(grid, {x, y}, grid_value)
    sorted_grid = sorted_grid ++ [{{x, y}, grid_value}]
    build_grid(grid, sorted_grid, raw_grid, grid_size, {x + 1, y})
  end

  defp calculate_scores(request) do
    scores = calculate_scores(%{}, request.assigns.grid, request.assigns.grid_size - 1, {0, 0})
    sorted_scores = Enum.sort_by(scores, &elem(&1, 1), &>=/2)

    request
    |> Request.assign(:scores, scores)
    |> Request.assign(:sorted_scores, sorted_scores)
  end

  defp calculate_scores(scores, grid, grid_size, {x, y}) when x > grid_size do
    calculate_scores(scores, grid, grid_size, {0, y + 1})
  end

  defp calculate_scores(scores, grid, grid_size, {x, y}) do
    if Map.has_key?(grid, {x, y}) do
      score = calculate_score(grid, {x, y})
      scores = Map.put(scores, {x, y}, score)
      calculate_scores(scores, grid, grid_size, {x + 1, y})
    else
      scores
    end
  end

  defp calculate_score(grid, {x, y}) do
    required_cells = get_required_cells(x, y)

    Enum.reduce(required_cells, 0, fn cell, score ->
      value = Map.get(grid, cell, 0)
      score + value
    end)
  end

  defp get_required_cells(x, y) do
    [
      {x - 1, y - 1},
      {x - 1, y},
      {x - 1, y + 1},
      {x, y - 1},
      {x, y},
      {x, y + 1},
      {x + 1, y - 1},
      {x + 1, y},
      {x + 1, y + 1}
    ]
  end

  defp build_output(request) do
    output =
      request.assigns.sorted_scores
      |> Enum.take(request.assigns.results_requested)
      |> Enum.map(fn {{x, y}, score} -> {x, y, score: score} end)

    Request.put_output(request, output)
  end
end
