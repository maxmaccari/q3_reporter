defmodule Q3Reporter.Core do
  @moduledoc """
  Module that contains the core logic of the q3_reporter.
  """

  alias Q3Reporter.Core.{Interpreter, Results}

  @type opts :: [{:mode, :by_game | :ranking}]

  @doc """
  Parse a log content into a `Q3Reporter.Core.Results` structure.

  ## Options
    * `:mode:` - `:by_game` or `:ranking`

  ## Example

    iex> Q3Reporter.Core.parse("  0:00 InitGame:")
    %Q3Reporter.Core.Results {
      :mode => :by_game,
      :games => [ %Q3Reporter.Core.Game{...} ]
    }
  """
  @spec interpret_log(String.t(), opts()) :: Results.t()
  def interpret_log(content, opts \\ []) do
    content
    |> Interpreter.interpret()
    |> Results.new(opts[:mode])
  end
end
