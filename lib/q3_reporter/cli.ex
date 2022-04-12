defmodule Q3Reporter.Cli do
  @moduledoc """
  Cli that read and parse a quake 3 logger showing the log summary.
  """

  alias Q3Reporter.{Parser, ResultPrinter, Supervisor}

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
      |> Parser.parse()
      |> print_result(opts)
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

  defp print_result(result, %{web: true, filename: path}) do
    Supervisor.start_link([result, path])
    Process.sleep(:infinity)
  end

  defp print_result(result, opts) do
    ResultPrinter.print(opts, result)
  end
end
