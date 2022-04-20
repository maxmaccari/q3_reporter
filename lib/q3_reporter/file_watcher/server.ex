defmodule Q3Reporter.FileWatcher.Server do
  @moduledoc false

  @timeout 100

  use GenServer

  @type state :: %{
          mtime: integer(),
          path: String.t(),
          subscribers: []
        }

  # Client

  @spec start_link(String.t(), keyword()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(path, opts \\ []) do
    GenServer.start_link(__MODULE__, path, opts)
  end

  def subscribe(file) do
    GenServer.call(file, :subscribe)
  end

  def unsubscribe(file) do
    GenServer.call(file, :unsubscribe)
  end

  # Server Callbacks

  @impl true
  @spec init(String.t()) :: {:ok, state} | {:stop, atom()}
  def init(path) do
    case File.stat(path) do
      {:ok, %{mtime: mtime}} ->
        :timer.send_interval(@timeout, :tick)

        {:ok, %{path: path, mtime: mtime, subscribers: []}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_call(:subscribe, {subscriber, _}, %{subscribers: subscribers} = state) do
    state = %{state | subscribers: [subscriber | subscribers]}

    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:unsubscribe, {subscriber, _}, %{subscribers: subscribers} = state) do
    state = %{state | subscribers: remove_subscriber(subscribers, subscriber)}

    {:reply, :ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    %{subscribers: subscribers, mtime: mtime, path: path} = state

    case File.stat!(path) do
      %{mtime: ^mtime} ->
        {:noreply, state}

      %{mtime: new_mtime} ->
        notify_subscribers(subscribers, new_mtime)

        {:noreply, %{state | mtime: new_mtime}}
    end
  end

  defp notify_subscribers(subscribers, mtime) do
    Enum.each(subscribers, fn subscriber ->
      send(subscriber, {:file_updated, self(), mtime})
    end)
  end

  defp remove_subscriber(subscribers, subscriber) do
    Enum.filter(subscribers, &(&1 !== subscriber))
  end
end
