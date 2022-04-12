defmodule Q3Reporter.Core.Game do
  alias Q3Reporter.Core.Player

  defstruct players: [],
            initialized_at: nil,
            shutdown_at: nil

  @type t :: %__MODULE__{
          players: list(Player.t())
        }

  @spec new() :: t()
  def new() do
    %__MODULE__{}
  end

  @spec initialize(t(), Time.t()) :: t()
  def initialize(%__MODULE__{} = game, time) do
    %{game | initialized_at: time}
  end

  @spec shutdown(t(), Time.t()) :: t()
  def shutdown(%__MODULE__{} = game, time) do
    %{game | shutdown_at: time}
  end

  @spec add_player(t(), Player.t()) :: t()
  def add_player(%__MODULE__{players: players} = game, %Player{} = player) do
    %{game | players: add_if_not_added(players, player)}
  end

  defp add_if_not_added(players, player) do
    if Enum.any?(players, &(&1.id === player.id)) do
      players
    else
      [player | players]
    end
  end

  @spec change_player_nickname(t(), Player.id(), String.t()) :: t()
  def change_player_nickname(%__MODULE__{players: players} = game, player_id, nickname) do
    players = update_player(players, player_id, &Player.set_nickname(&1, nickname))

    %{game | players: players}
  end

  @spec connect_player(t(), Player.id()) :: t()
  def connect_player(%__MODULE__{players: players} = game, player_id) do
    %{game | players: update_player(players, player_id, &Player.connect/1)}
  end

  @spec disconnect_player(t(), Player.id()) :: t()
  def disconnect_player(%__MODULE__{players: players} = game, player_id) do
    %{game | players: update_player(players, player_id, &Player.disconnect/1)}
  end

  @spec kill_player(t(), Player.id() | :world, Player.id()) :: t()
  def kill_player(%__MODULE__{players: players} = game, :world, player_id) do
    %{game | players: update_player(players, player_id, &Player.increment_deaths/1)}
  end

  def kill_player(%__MODULE__{players: players} = game, player_id, player_id) do
    %{game | players: update_player(players, player_id, &Player.increment_deaths/1)}
  end

  def kill_player(%__MODULE__{players: players} = game, killer_id, killed_id) do
    %{game | players: maybe_kill_player(players, killer_id, killed_id)}
  end

  defp maybe_kill_player(players, killer_id, killed_id) do
    if player_exist?(players, killer_id) && player_exist?(players, killed_id) do
      players
      |> update_player(killer_id, &Player.increment_kills/1)
      |> update_player(killed_id, &Player.increment_deaths/1)
    else
      players
    end
  end

  defp player_exist?(players, player_id), do: Enum.any?(players, &(&1.id === player_id))

  defp update_player(players, player_id, fun) do
    Enum.map(players, fn
      %{id: ^player_id} = player -> fun.(player)
      player -> player
    end)
  end

  @spec total_kills(t()) :: integer()
  def total_kills(%__MODULE__{players: players}) do
    players
    |> Enum.map(& &1.kills)
    |> Enum.sum()
  end

  @spec status(t()) :: :created | :initialized | :shutdown
  def status(%__MODULE__{initialized_at: nil, shutdown_at: nil}), do: :created
  def status(%__MODULE__{shutdown_at: nil}), do: :initialized
  def status(%__MODULE__{}), do: :shutdown
end
