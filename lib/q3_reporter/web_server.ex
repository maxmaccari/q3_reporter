defmodule Q3Reporter.WebServer do
  alias Q3Reporter.WebServer.Handler

  require Logger

  def start(result) do
    port = (System.get_env("PORT") || "8080") |> String.to_integer()

    options = [:binary, backlog: 10, packet: :raw, active: false, reuseaddr: true]

    {:ok, listen_socket} =
      :gen_tcp.listen(port, options)

    IO.puts("\n🎧  Listening for connection requests on port #{port}...\n")

    accept_loop(listen_socket, result)
  end

  def accept_loop(listen_socket, result) do
    Logger.debug("⌛  Waiting to accept a client connection...\n")

    client_socket = accept(listen_socket)

    pid = spawn fn -> serve(client_socket, result) end

    :ok = :gen_tcp.controlling_process(client_socket, pid)

    accept_loop(listen_socket, result)
  end

  defp accept(listen_socket) do
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    Logger.debug("⚡️  Connection accepted!\n")

    client_socket
  end

  defp serve(client_socket, result) do
    client_socket
      |> receive_request()
      |> handle_request(result)
      |> send_response()
  end

  defp receive_request(client_socket) do
    case :gen_tcp.recv(client_socket, 0) do
      {:ok, request} ->
        Logger.debug("➡️  Received request!")

        {client_socket, request}

      {:error, :closed} ->
        :error
    end
  end

  defp handle_request({client_socket, request}, result) do
    {client_socket, Handler.handle(request, result)}
  end

  defp handle_request(:error, _result), do: :error

  defp send_response({client_socket, response}) do
    :ok = :gen_tcp.send(client_socket, response)
    Logger.debug("⬅️  Sent response!")

    :ok = :gen_tcp.close(client_socket)
  end

  defp send_response(:error), do: :error
end
