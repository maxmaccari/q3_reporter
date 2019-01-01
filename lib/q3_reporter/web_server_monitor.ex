defmodule Q3Reporter.WebServerMonitor do
  @name :web_server_monitor

  def start(result) do
    pid = spawn(fn ->
      server_pid = start_server(result)
      Process.flag(:trap_exit, true)

      listen_loop({server_pid, result})
    end)
    Process.register(pid, @name)

    pid
  end

  def get_server(pid) do
    send(pid, {:get_server, self()})

    receive do
      {:server_pid, server_pid} ->
        server_pid
    end
  end

  def listen_loop({server_pid, result}) do
    receive do
      {:get_server, sender} ->
        send(sender, {:server_pid, server_pid})

        listen_loop({server_pid, result})
      {:EXIT, ^server_pid, _reason} ->
        server_pid = start_server(result)

        listen_loop({server_pid, result})
      _ ->
        listen_loop({server_pid, result})
    end
  end

  defp start_server(result) do
    server_pid = spawn_link(Q3Reporter.WebServer, :start, [result])
    Process.register(server_pid, :web_server)

    server_pid
  end
end
