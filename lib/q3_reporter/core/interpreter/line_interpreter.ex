defmodule Q3Reporter.Core.Interpreter.LineInterpreter do
  @moduledoc false

  @doc false
  def parse_line(<<time::binary-7, "InitGame:", _::binary>>),
    do: {:init_game, parse_time(time)}

  def parse_line(<<time::binary-7, "ShutdownGame:", _::binary>>),
    do: {:shutdown_game, parse_time(time)}

  def parse_line(<<_time::binary-7, "ClientConnect: ", player_id::binary>>),
    do: {:client_connect, player_id}

  def parse_line(<<_time::binary-7, "ClientDisconnect: ", player_id::binary>>),
    do: {:client_disconnect, player_id}

  def parse_line(<<_time::binary-7, "ClientBegin: ", player_id::binary>>),
    do: {:client_begin, player_id}

  def parse_line(<<_time::binary-7, "ClientUserinfoChanged: ", info::binary>>) do
    [player_id, rest] = String.split(info, " ", parts: 2, trim: true)
    new_nickname = rest |> String.split("\\") |> Enum.at(1)

    {:client_nickname_changed, player_id, new_nickname}
  end

  def parse_line(<<_time::binary-7, "Kill: ", info::binary>>) do
    [killer_id, killed_id, _] = String.split(info, " ", parts: 3)

    killer_id = if killer_id == "1022", do: :world, else: killer_id

    {:kill, killer_id, killed_id}
  end

  def parse_line(_), do: :ignore

  defp parse_time(time) do
    [hour, minutes] = time |> String.trim() |> String.split(":")
    hour = String.to_integer(hour)
    minutes = String.to_integer(minutes)

    Time.new!(hour, minutes, 0)
  end
end
