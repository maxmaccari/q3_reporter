defmodule Q3Reporter.WebServerMonitor do
  use GenServer

  alias Q3Reporter.ResultServer

  @name :web_server_monitor

  # Client

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def get_server() do
    GenServer.call(@name, :get_server)
  end

  # Server

  def init(:ok) do
    server_pid = start_server()
    Process.flag(:trap_exit, true)

    {:ok, server_pid}
  end

  def handle_call(:get_server, _from, server_pid) do
    {:reply, server_pid, server_pid}
  end

  def handle_info({:EXIT, _pid, _reason},  _server_pid) do
    server_pid = start_server()

    {:noreply, server_pid}
  end

  defp start_server() do
    result = ResultServer.get_result()

    server_pid = spawn_link(Q3Reporter.WebServer, :start, [result])
    Process.register(server_pid, :web_server)

    server_pid
  end
end
