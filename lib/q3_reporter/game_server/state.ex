defmodule Q3Reporter.GameServer.State do
  @moduledoc false

  alias Q3Reporter.Core
  alias Q3Reporter.Core.{Game, Results}

  defstruct path: nil,
            watch_pid: nil,
            games: [],
            by_game: nil,
            ranking: nil,
            subscribers: [],
            watcher_pid: nil,
            watcher: &__MODULE__.__default_watcher__/1,
            loader: &__MODULE__.__default_loader__/1

  @type mode :: :by_game | :ranking

  @type watcher :: (String.t() -> {:ok, pid} | {:error, any()})
  @type loader :: (String.t() -> {:ok, list(Game.t())} | {:error, any()})

  @type t :: %__MODULE__{
          path: String.t(),
          watch_pid: pid(),
          games: list(Game.t()),
          by_game: Results.t(),
          ranking: Results.t(),
          subscribers: list({pid, mode}),
          watcher_pid: pid | nil,
          watcher: watcher(),
          loader: loader()
        }

  @spec new(keyword) :: t
  def new(attrs \\ []) do
    struct!(__MODULE__, attrs)
  end

  @spec update_games(t(), list(Game.t()) | []) :: t()
  def update_games(%__MODULE__{} = state, games) do
    state
    |> put_games(games)
    |> generate_by_games()
    |> generate_ranking()
  end

  @spec update_watcher_pid(t(), pid) :: t()
  def update_watcher_pid(%__MODULE__{} = state, pid) do
    %{state | watcher_pid: pid}
  end

  defp put_games(state, games), do: %{state | games: games}

  defp generate_by_games(%__MODULE__{games: games} = state) do
    %{state | by_game: Core.games_to_results(games, :by_game)}
  end

  defp generate_ranking(%__MODULE__{games: games} = state) do
    %{state | ranking: Core.games_to_results(games, :ranking)}
  end

  @spec subscribe(t, pid, mode) :: t
  def subscribe(%__MODULE__{subscribers: subscribers} = state, pid, mode \\ :by_game) do
    if subscribed?(state, pid, mode) do
      state
    else
      %{state | subscribers: [{pid, mode} | subscribers]}
    end
  end

  @spec unsubscribe(t, pid, mode) :: t
  def unsubscribe(%__MODULE__{subscribers: subscribers} = state, pid, mode \\ :by_game) do
    %{state | subscribers: Enum.reject(subscribers, &(&1 === {pid, mode}))}
  end

  @spec subscribed?(t, pid, mode) :: boolean
  def subscribed?(%__MODULE__{subscribers: subscribers}, pid, mode) do
    Enum.any?(subscribers, &(&1 === {pid, mode}))
  end

  @spec results(t(), mode) :: Results.t()
  def results(%__MODULE__{by_game: by_game}, :by_game), do: by_game
  def results(%__MODULE__{ranking: ranking}, :ranking), do: ranking

  @spec start_watcher(t()) :: {:error, any} | {:ok, t()}
  def start_watcher(%__MODULE__{watcher: watcher, path: path} = state) do
    case watcher.(path) do
      {:ok, pid} -> {:ok, update_watcher_pid(state, pid)}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec load_games(t()) :: {:error, any} | {:ok, t()}
  def load_games(%__MODULE__{loader: loader, path: path} = state) do
    case loader.(path) do
      {:ok, games} -> {:ok, update_games(state, games)}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec __default_watcher__(String.t()) :: {:ok, pid}
  def __default_watcher__(_path), do: {:ok, spawn(fn -> :ok end)}

  @spec __default_loader__(String.t()) :: {:ok, []}
  def __default_loader__(_path), do: {:ok, []}
end
