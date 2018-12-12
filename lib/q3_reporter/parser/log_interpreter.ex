defmodule Q3Reporter.Parser.LogInterpreter do
  def interpret_line("InitGame:" <> _) do
    :new_game
  end

  def interpret_line("ClientConnect: " <> id) do
    {:connect_player, id}
  end

  def interpret_line("ClientUserinfoChanged: " <> info) do
    [id, rest] = String.split(info, " ", parts: 2, trim: true)
    new_nickname = rest |> String.split("\\") |> Enum.at(1)

    {:change_player_nickname, id, new_nickname}
  end

  def interpret_line("Kill: " <> info) do
    [killer_id, killed_id, _] = String.split(info, " ", parts: 3)
    killer_id = if killer_id == "1022", do: :world, else: killer_id

    {:kill, killer_id, killed_id}
  end

  def interpret_line(_) do
    nil
  end
end
