defmodule Q3Reporter.WebServer do
  alias Q3Reporter.WebServer.Handler

  @port 8080
  def start(result) do
    {:ok, listen_socket} = :gen_tcp.listen(@port, [:binary, packet: :raw, active: false, reuseaddr: true])

    IO.puts("\n🎧  Listening for connection requests on port #{@port}...\n")

    accept_loop(listen_socket, result)
  end

  def accept_loop(listen_socket, result) do
    IO.puts "⌛  Waiting to accept a client connection...\n"

    listen_socket
    |> accept()
    |> receive_request()
    |> handle_request(result)
    |> send_response()

    accept_loop(listen_socket, result)
  end

  defp accept(listen_socket) do
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts "⚡️  Connection accepted!\n"

    client_socket
  end

  defp receive_request(client_socket) do
    case :gen_tcp.recv(client_socket, 0) do
      {:ok, request} ->
        IO.puts "➡️  Received request:\n"

        {client_socket, request}
      {:error, :closed} -> :error
    end
  end

  defp handle_request({client_socket, request}, result) do
    {client_socket, Handler.handle(request, result)}
  end

  defp handle_request(:error, _result), do: :error

  defp send_response({client_socket, response}) do
    :ok = :gen_tcp.send(client_socket, response)
    IO.puts "⬅️  Sent response:\n"

    :ok = :gen_tcp.close(client_socket)
  end

  defp send_response(:error), do: :error
end
