defmodule Q3Reporter.Cli do
  @moduledoc """
  Cli that read and parse a quake 3 logger showing the log summary.
  """

  alias Q3Reporter.LogParser

  @doc """
  Function that execute the log parsing by the given args.

  ## Examples

      iex> Q3Reporter.main([])
      :ok

  """
  def main(args \\ []) do
    with {:ok, opts} <- parse_args(args),
         {:ok, results} <- LogParser.parse(opts.filename, mode: opts.mode) do
      display(results, opts)
    else
      {:error, message} -> IO.puts(:stderr, message)
    end
  end

  defp parse_args([]) do
    message = """
    usage: q3_reporter [options] <filename>

    Options:
      --ranking => Output ranking instead summary
      --json => Output result as json
    """

    {:error, message}
  end

  @permitted_args [json: :boolean, ranking: :boolean]
  defp parse_args(args) do
    {opts, [filename], _} = OptionParser.parse(args, strict: @permitted_args)

    opts = %{
      json: Keyword.get(opts, :json, false),
      mode: if(opts[:ranking], do: :ranking, else: :by_game),
      filename: filename
    }

    {:ok, opts}
  end

  defp display(result, %{json: true}) do
    result
    |> Jason.encode!(pretty: true)
    |> IO.puts()
  end

  defp display(result, _opts), do: IO.puts(result)
end
