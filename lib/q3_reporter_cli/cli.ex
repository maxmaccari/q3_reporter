defmodule Q3ReporterCli.Cli do
  @moduledoc """
  Cli that read and parse a quake 3 logger showing the log summary.
  """

  alias Q3Reporter

  @type args :: %{
          json: boolean(),
          mode: :ranking | :by_game,
          filename: String.t(),
          watch: boolean()
        }

  @doc """
  Function that execute the log parsing by the given args.

  ## Examples

      iex> Q3Reporter.main([])
      :ok

  """

  def main(args \\ []) do
    with {:ok, opts} <- parse_args(args),
         {:ok, results} <- Q3Reporter.parse(opts.filename, mode: opts.mode) do
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
      --watch => Watch for log changes
    """

    {:error, message}
  end

  @permitted_args [json: :boolean, ranking: :boolean, watch: :boolean]
  @spec parse_args(list()) :: {:ok, args}
  defp parse_args(args) do
    {opts, [filename], _} = OptionParser.parse(args, strict: @permitted_args)

    opts = %{
      json: Keyword.get(opts, :json, false),
      mode: if(opts[:ranking], do: :ranking, else: :by_game),
      filename: filename,
      watch: opts[:watch]
    }

    {:ok, opts}
  end

  defp display(result, %{watch: true} = opts), do: watch(result, opts)
  defp display(result, %{json: json}), do: do_display(result, json)

  defp do_display(result, true) do
    result
    |> Jason.encode!(pretty: true)
    |> IO.puts()
  end

  defp do_display(result, false), do: IO.puts(result)

  defp watch(result, opts) do
    %{mode: mode, json: json, filename: path} = opts
    Q3Reporter.watch_games(path, mode)

    watch_display(result, json)

    do_watch(path, mode, json)
  end

  defp do_watch(path, mode, json) do
    receive do
      :interrupt ->
        :ok

      {:game_results, ^path, ^mode, result} ->
        watch_display(result, json)

        do_watch(path, mode, json)
    end
  end

  defp watch_display(result, json) do
    clear()
    do_display(result, json)
    exit_instructions()
  end

  defp clear, do: IO.ANSI.clear() |> IO.puts()
  defp exit_instructions, do: IO.puts("\n\nPress Ctrl/Command + C to exit...")
end
