defmodule Q3Reporter do
  @moduledoc """
  Read and parse a quake 3 logger showing the log summary.
  """

  alias Q3Reporter.Parser

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
    usage: q3_reporter [filename]
    """

    {:error, message}
  end

  @permitted_args [json: :boolean]
  defp parse_args(args) do
    {opts, filename, _} = OptionParser.parse(args, strict: @permitted_args)

    opts = %{
      json: Keyword.get(opts, :json, false),
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

  defp print_result({:ok, %{json: false}, result}) do
    result
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {game, id} ->
      players =
        game.players
        |> Enum.map(fn player ->
          "- #{player.nickname}:\n" <>
          "      Kills: #{player.kills}\n" <>
          "      Deaths: #{player.deaths}"
        end)
        |> Enum.join("\n    ")

      """
        Game #{id}:
          #{players}
          => Total Kills: #{game.total_kills}
      """
    end)
    |> Enum.reverse()
    |> Enum.join("\n")
    |> IO.puts()
  end

  defp print_result({:ok, %{json: true}, result}) do
    result
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {game, id} ->
      game =
        game.players
        |> Enum.map(fn player ->
          {player.nickname, %{"kills" => player.kills, "deaths" => player.deaths}}
        end)
        |> Enum.into(%{})
        |> Map.put("totalKills", game.total_kills)

      {"game#{id}", game}
    end)
    |> Enum.into(%{})
    |> Jason.encode!(pretty: true)
    |> IO.puts()
  end

  defp print_result({:error, message}) do
    IO.puts(message)
  end
end
