defmodule Q3Reporter do
  @moduledoc """
  Module that contains the logic for parsing Quake 3 logs.
  """

  alias Q3Reporter.Core
  alias Q3Reporter.Core.Results
  alias Q3Reporter.Log

  @type opts :: keyword()

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
  @spec parse(String.t(), opts()) ::
          {:ok, Results.t()} | {:error, String.t()}
  def parse(path, opts \\ []) do
    with {:ok, content} <- Log.read(path, opts[:log_adapter]),
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

  alias Q3Reporter.UpdateChecker

  @doc """
  Start watching for log file updates.

  It returns :ok if it is sucesfull, or {:error, reason} if you have any problem.

  ## Example

    iex> Q3Reporter.start_watch_log_updates("noexist")
    {:error, :enoent}
    iex> Q3Reporter.start_watch_log_updates("example.log")
    :ok
    iex> flush()
    {:updated, #PID<0.248.0>, ~N[2022-04-30 13:26:47]}
  """
  @spec start_watch_log_updates(String.t(), atom() | nil) ::
          :ok | {:error, any()}
  def start_watch_log_updates(path, adapter \\ nil) do
    with {:ok, updater} <- UpdateChecker.open(path, &Q3Reporter.Log.mtime(&1, adapter)),
         :ok <- UpdateChecker.subscribe(updater) do
      {:ok, updater}
    end
  end

  @doc """
  Stop watching for log file updates.

  It returns :ok if it is sucesfull, or :error if the server does not exist.

  ## Example

    iex> {:ok, pid} = Q3Reporter.start_watch_log_updates("example.log")
    iex> Q3Reporter.stop(pid)
    :ok
    iex> Q3Reporter.stop(pid)
    :error
  """
  @spec stop_watch_log_updates(pid) :: :ok
  def stop_watch_log_updates(updated) do
    UpdateChecker.stop(updated)
  catch
    :exit, _ -> :error
  end
end
