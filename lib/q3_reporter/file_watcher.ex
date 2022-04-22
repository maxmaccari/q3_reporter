defmodule Q3Reporter.FileWatcher do
  @moduledoc """
  It is a service that monitor for file updates.

  You start Q3Reporter.FileWatcher directly in your supervision tree:

      {Q3Reporter.FileWatcher.Supervisor, []}

  You can now use the functions in this module to open and subscribe for file changes:

      iex> Q3Reporter.FileWatcher
      iex> {:ok, file} = FileWatcher.open("example")
      {:ok, #PID<0, 100, 0>}
      iex> FileWatcher.subscribe(file)
      :ok
      iex> flush()
      {:file_updated, #PID<0.302.0>, {{2022, 4, 22}, {0, 40, 11}}}
      :ok
      iex> FileWatcher.unsubscribe(file)
      iex> flush()
      :ok
      iex> FileWatcher.close(file)
      :ok

  """

  alias Q3Reporter.FileWatcher.{Server, Supervisor}

  @doc """
  Open a file to be monitored for the given `path`.
  """
  @spec open(String.t()) :: :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  defdelegate open(path), to: Supervisor, as: :start_child

  @spec subscribed?(pid, pid) :: boolean()
  @doc """
  Check if the current process or the given `pid` is subscribed to the given
  `file_pid`.
  """
  defdelegate subscribed?(file_pid, pid \\ self()), to: Server

  @spec subscribe(pid) :: :ok
  @doc """
  Subscribe to a watched files changes.

  The subscribed server receives messages when the file is updated
  in the following format:

      {:file_updated, file_pid, mtime}
  """
  defdelegate subscribe(pid), to: Server

  @doc """
  Unsubscribe to a watched files changes. It reverts the `subscribe/1` effect.
  """
  defdelegate unsubscribe(pid), to: Server

  @doc """
  Close the watched file. So it changes won't be monitored anymore
  """
  defdelegate close(pid), to: Server
end
