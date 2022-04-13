defmodule Q3Reporter.UpdaterServer do
  use GenServer

  alias Q3Reporter.{Parser, ResultServer}

  @name :updater_server
  @timeout 1000

  # Client

  def start_link(path) do
    GenServer.start_link(__MODULE__, path, name: @name)
  end

  def init(path) do
    if File.exists?(path) do
      %{mtime: mtime} = File.stat!(path)
      Process.send_after(@name, :TICK, @timeout)

      {:ok, {path, mtime}}
    else
      {:error, :enoent}
    end
  end

  # Server

  def handle_info(:TICK, {path, _mtime} = state) do
    new_state =
      if File.exists?(path) && file_updated?(state) do
        %{mtime: new_mtime} = File.stat!(path)
        update_result(path)

        {path, new_mtime}
      else
        state
      end

    Process.send_after(@name, :TICK, @timeout)

    {:noreply, new_state}
  end

  def terminate(reason, _state) do
    IO.inspect(reason)
  end

  defp file_updated?({path, mtime}) do
    %{mtime: new_mtime} = File.stat!(path)

    mtime < new_mtime
  end

  defp update_result(path) do
    path
    |> File.read!()
    |> Parser.parse()
    |> ResultServer.update_result()
  end
end
