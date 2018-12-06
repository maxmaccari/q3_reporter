defmodule Q3Reporter do
  @moduledoc """
  Read and parse a quake 3 logger showing the log summary.
  """

  @doc """
  Function that execute the log parsing by the given args.

  ## Examples

      iex> Q3Reporter.main([])
      nil

  """
  def main(args \\ []) do
    args
    |> parse_args
    |> open
    |> read
    |> result
  end

  defp parse_args([]) do
    message = """
    usage: q3_reporter [filename]
    """

    IO.puts(message)
    System.halt(1)
  end

  @permitted_args []
  defp parse_args(args) do
    {opts, filename, _} = OptionParser.parse(args, strict: @permitted_args)

    {opts, filename}
  end

  defp open({opts, filepath}) do
    file = case File.open(filepath, [:read]) do
      {:ok, file} -> file
      {:error, :enoent} ->
        IO.puts(:stderr, "'#{filepath}' not found...")

        System.stop(1)
    end

    {opts, file}
  end

  defp read({opts, file}) do
    content = IO.read(file, :all)
    :ok = File.close(file)

    {opts, content}
  end

  def result({_opts, content}) do
    IO.puts(content)
  end
end
