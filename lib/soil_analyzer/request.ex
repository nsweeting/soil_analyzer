defmodule SoilAnalyzer.Request do
  @moduledoc """
  A common data structure used for all soil analysis tests.
  """

  alias SoilAnalyzer.Request

  @enforce_keys [:processor, :input]
  defstruct [
    :processor,
    :input,
    :output,
    valid?: true,
    errors: [],
    assigns: %{}
  ]

  @type t :: %__MODULE__{
          processor: SoilAnalyzer.Processor.t(),
          input: any(),
          output: any(),
          valid?: boolean(),
          errors: [binary()],
          assigns: map()
        }

  ##################################
  # Public API
  ##################################

  @doc """
  Creates a new request using the provided `processor` and `input`.
  """
  @spec new(SoilAnalyzer.Processor.t(), any()) :: SoilAnalyzer.Request.t()
  def new(processor, input), do: %__MODULE__{processor: processor, input: input}

  @doc """
  Puts the provided final `output` into the `request`.
  """
  @spec put_output(SoilAnalyzer.Request.t(), any()) :: SoilAnalyzer.Request.t()
  def put_output(request, output), do: %{request | output: output}

  @doc """
  Assigns a `value` to a `key` within the `request`.
  """
  @spec assign(SoilAnalyzer.Request.t(), atom, term) :: SoilAnalyzer.Request.t()
  def assign(%Request{assigns: assigns} = request, key, value) when is_atom(key) do
    %{request | assigns: Map.put(assigns, key, value)}
  end

  @doc """
  Adds an `error` to the list of `request` errors.
  """
  @spec add_error(SoilAnalyzer.Request.t(), binary()) :: SoilAnalyzer.Request.t()
  def add_error(%Request{errors: errors} = request, error) do
    %{request | valid?: false, errors: [error | errors]}
  end
end
