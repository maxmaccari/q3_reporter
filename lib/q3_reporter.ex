defmodule Q3Reporter do
  @moduledoc """
  Module that contains the logic for parsing Quake 3 logs.
  """

  alias Q3Reporter.Log
  alias Q3Reporter.Core
  alias Q3Reporter.Core.Results

  @doc """
  Parse a log content into a `Q3Reporter.Core.Results` structure from a file.

  ## Options
    * `:mode:` - `:by_game` or `:ranking`

  ## Example

    iex> Q3Reporter.parse_file("/path/to/log.txt")
    {:ok, %Q3Reporter.Core.Results {
      :mode => :by_game,
      :games => [ %Q3Reporter.Core.Game{...} ]
    }}
  """
  @spec parse(String.t(), Core.opts()) ::
          {:ok, Results.t()} | {:error, String.t()}
  def parse(path, opts \\ []) do
    with {:ok, content} <- Log.read(path),
         results <- Core.log_to_results(content, opts[:mode]) do
      {:ok, results}
    else
      {:error, :enoent} ->
        {:error, "'#{path}' not found..."}

      # coveralls-ignore-start
      {:error, :eacces} ->
        {:error, "You don't have permission to open '#{path}..."}

      {:error, :enomem} ->
        {:error, "There's not enough memory to open '#{path}..."}

      {:error, _} ->
        {:error, "Error trying to open '#{path}'"}
        # coveralls-ignore-stop
    end
  end
end
