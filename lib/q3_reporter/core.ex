defmodule Q3Reporter.Core do
  alias Q3Reporter.Core.{Interpreter, Results}

  def interpret_log(content, opts \\ []) do
    content
    |> Interpreter.interpret()
    |> process_results(opts[:mode])
  end

  defp process_results(games, :ranking), do: Results.general(games)

  defp process_results(games, _), do: Results.by_game(games)
end
