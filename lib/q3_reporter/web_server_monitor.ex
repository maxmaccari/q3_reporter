defmodule Q3Reporter.WebServerMonitor do
  use GenServer

  @name :web_server_monitor

  # Client

  def start_link(results) do
    GenServer.start_link(__MODULE__, results, name: @name)
  end

  def get_server() do
    GenServer.call(@name, :get_server)
  end

  # Server

  def init(results) do
    server_pid = start_server(results)
    Process.flag(:trap_exit, true)

    {:ok, {server_pid, results}}
  end

  def handle_call(:get_server, _from, {server_pid, _results} = state) do
    {:reply, server_pid, state}
  end

  def handle_info({:EXIT, _pid, _reason},  {_server_pid, results}) do
    server_pid = start_server(results)

    {:noreply, {server_pid, results}}
  end

  defp start_server(result) do
    server_pid = spawn_link(Q3Reporter.WebServer, :start, [result])
    Process.register(server_pid, :web_server)

    server_pid
  end
end
