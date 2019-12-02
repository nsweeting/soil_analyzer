defmodule SoilAnalyzer.Processors.WaterConcentrationTest do
  use ExUnit.Case

  alias SoilAnalyzer.Processors.WaterConcentration

  describe "run/1" do
    test "will return an error when input is not a string" do
      request = WaterConcentration.run([])
      assert_has_error(request, "input must be a string")
    end

    test "will return an error when input not in format `t n *grid`" do
      request = WaterConcentration.run("1")
      assert_has_error(request, "input must be in format 't n *grid'")

      request = WaterConcentration.run("1 1")
      assert_has_error(request, "input must be in format 't n *grid'")
    end

    test "will return an error when results requested is not an integer" do
      request = WaterConcentration.run("x 1 1")
      assert_has_error(request, "results_requested must be an integer")
    end

    test "will return an error when results requested is less than 0" do
      request = WaterConcentration.run("-1 1 1")
      assert_has_error(request, "results_requested cannot be less than 0")
    end

    test "will return an error when grid size is not an integer" do
      request = WaterConcentration.run("1 x 1")
      assert_has_error(request, "grid_size must be an integer")
    end

    test "will return an error when grid size is less than 1" do
      request = WaterConcentration.run("1 0 1")
      assert_has_error(request, "grid_size cannot be less than 1")
    end

    test "will return an error when grid size is greater than grid" do
      request = WaterConcentration.run("1 2 1")
      assert_has_error(request, "grid size does not match grid")
    end

    test "will return an error when raw grid size is greater than grid size" do
      request = WaterConcentration.run("1 2 1 1 1")
      assert_has_error(request, "grid size does not match grid")
    end

    test "will return an error when grid value is not an integer" do
      request = WaterConcentration.run("1 1 1 x")
      assert_has_error(request, "x must be an integer")
    end

    test "will return an error when grid value is less than 0" do
      request = WaterConcentration.run("1 1 1 -1")
      assert_has_error(request, "-1 cannot be less than 0")
    end

    test "will return an error when grid value is greater than 9" do
      request = WaterConcentration.run("1 1 1 10")
      assert_has_error(request, "10 cannot be greater than 9")
    end

    test "will return the expected output #1" do
      request = WaterConcentration.run(" 1 5 5 3 1 2 0 4 1 1 3 2 2 3 2 4 3 0 2 3 3 2 1 0 2 4 3")
      assert %{output: [{3, 3, score: 26}]} = request
    end

    test "will return the expected output #2" do
      request = WaterConcentration.run("3 4 2 3 2 1 4 4 2 0 3 4 1 1 2 3 4 4")
      assert %{output: [{1, 2, score: 27}, {1, 1, score: 25}, {2, 2, score: 23}]} = request
    end
  end

  def assert_has_error(request, error) do
    assert %{valid?: false, errors: [^error]} = request
  end
end
