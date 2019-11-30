defmodule SoilAnalyzer.Processor do
  @moduledoc """
  A behaviour for building soil analysis processors.
  """

  @type t :: module()
  @type input :: any()
  @type output :: SoilAnalyzer.Request.t()

  @callback run(input()) :: output()
end
