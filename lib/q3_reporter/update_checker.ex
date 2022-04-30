defmodule Q3Reporter.UpdateChecker do
  @moduledoc """
  It is a service to help to check updates automatically.

  You start Q3Reporter.UpdateChecker directly in your supervision tree:

      {Q3Reporter.UpdateChecker, []}

  You can now use the functions in this module to open and subscribe for updates:

      iex> Q3Reporter.UpdateChecker
      iex> {:ok, file} = UpdateChecker.open("example", &Q3Reporter.Log.mtime/1)
      {:ok, #PID<0, 100, 0>}
      iex> UpdateChecker.subscribe(file)
      :ok
      iex> flush()
      {:updated, #PID<0.302.0>, {{2022, 4, 22}, {0, 40, 11}}}
      :ok
      iex> UpdateChecker.unsubscribe(file)
      iex> flush()
      :ok
      iex> UpdateChecker.stop(file)
      :ok

  """

  alias Q3Reporter.UpdateChecker.{Server, Supervisor}

  @type checker :: Q3Reporter.UpdateChecker.State.checker()

  @doc """
  Open a file to be monitored for the given `path`.
  """
  @spec open(String.t(), checker, keyword()) :: DynamicSupervisor.on_start_child()
  def open(path, checker, opts \\ []) do
    opts =
      opts
      |> Keyword.put(:path, path)
      |> Keyword.put(:checker, checker)

    Supervisor.start_child(opts)
  end

  @spec subscribed?(pid, pid) :: boolean()
  @doc """
  Check if the current process or the given `pid` is subscribed to the given
  `server_pid`.
  """
  defdelegate subscribed?(server_pid, pid \\ self()), to: Server

  @spec subscribe(pid) :: :ok
  @doc """
  Subscribe to a monitoring modify server.

  The subscribed process receives messages when the file is updated
  in the following format:

      {:file_updated, file_pid, mtime}
  """
  defdelegate subscribe(pid), to: Server

  @doc """
  Unsubscribe to a monitoring modify server. It reverts the `subscribe/1` effect.
  """
  defdelegate unsubscribe(pid), to: Server

  @doc """
  Stop the monitoring server. So it changes won't be monitored anymore
  """
  defdelegate stop(pid), to: Server

  # coveralls-ignore-start
  @doc false
  defdelegate start_link(opts \\ []), to: Supervisor

  @doc false
  defdelegate child_spec(params), to: Supervisor
  # coveralls-ignore-end
end
