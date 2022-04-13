defmodule Q3Reporter.Core do
  alias Q3Reporter.Core.{Interpreter, Results}

  @type opts :: keyword({:mode, :by_game | :ranking | nil})

  @spec interpret_log(String.t(), opts()) :: Results.t()
  def interpret_log(content, opts \\ []) do
    content
    |> Interpreter.interpret()
    |> Results.new(opts[:mode])
  end
end
