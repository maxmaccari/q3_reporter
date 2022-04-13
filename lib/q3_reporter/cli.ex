defmodule Q3Reporter.Cli do
  @moduledoc """
  Cli that read and parse a quake 3 logger showing the log summary.
  """

  alias Q3Reporter.Supervisor
  alias Q3Reporter.Core.{LogInterpreter, Ranking}

  @doc """
  Function that execute the log parsing by the given args.

  ## Examples

      iex> Q3Reporter.main([])
      :ok

  """
  def main(args \\ []) do
    with {:ok, opts} <- parse_args(args),
         {:ok, log} <- read_log(opts.filename) do
      log
      |> LogInterpreter.interpret()
      |> format(opts)
      |> display(opts)
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
      --web => Start a webserver with ranking and game summary
    """

    {:error, message}
  end

  @permitted_args [json: :boolean, ranking: :boolean, web: :boolean]
  defp parse_args(args) do
    {opts, [filename], _} = OptionParser.parse(args, strict: @permitted_args)

    opts = %{
      json: Keyword.get(opts, :json, false),
      ranking: Keyword.get(opts, :ranking, false),
      web: Keyword.get(opts, :web, false),
      filename: filename
    }

    {:ok, opts}
  end

  defp read_log(path) do
    case File.read(path) do
      {:ok, log} -> {:ok, log}
      {:error, :enoent} -> {:error, "'#{path}' not found..."}
      {:error, :eacces} -> {:error, "You don't have permission to open '#{path}..."}
      {:error, :enomem} -> {:error, "There's not enough memory to open '#{path}..."}
      {:error, _} -> {:error, "Error trying to open '#{path}'"}
    end
  end

  defp format(result, %{ranking: true}), do: Ranking.general(result)
  defp format(result, _opts), do: Ranking.by_game(result)

  defp display(result, %{json: true}) do
    result
    |> Jason.encode!(pretty: true)
    |> IO.puts()
  end

  defp display(result, _opts), do: IO.puts(result)
end
