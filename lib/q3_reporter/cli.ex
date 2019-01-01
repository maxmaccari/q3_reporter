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
    args
    |> parse_args
    |> open_file
    |> read_file
    |> parse
    |> print_result
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
    {opts, filename, _} = OptionParser.parse(args, strict: @permitted_args)

    opts = %{
      json: Keyword.get(opts, :json, false),
      ranking: Keyword.get(opts, :ranking, false),
      web: Keyword.get(opts, :web, false),
      filename: filename
    }

    {:ok, opts}
  end

  defp open_file({:ok, %{filename: filepath} = opts}) do
    case File.open(filepath, [:read]) do
      {:ok, file} -> {:ok, opts, file}
      {:error, :enoent} -> {:error, "'#{filepath}' not found..."}
      {:error, _} -> {:error, "Error trying to open '#{filepath}'"}
    end
  end

  defp open_file(error), do: error

  defp read_file({:ok, opts, file}) do
    content = IO.read(file, :all)
    :ok = File.close(file)

    {:ok, opts, content}
  end

  defp read_file(error), do: error

  defp parse({:ok, opts, content}) do
    result = Parser.parse(content)

    {:ok, opts, result}
  end

  defp parse(error), do: error

  defp print_result({:ok, %{web: true}, result}) do
    Supervisor.start_link(result)
  end

  defp print_result({:ok, opts, result}) do
    ResultPrinter.print(opts, result)
  end

  defp print_result({:error, message}) do
    IO.puts(message)
  end
end
