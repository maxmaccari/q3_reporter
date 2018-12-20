defmodule Q3Reporter.Parser.Player do
  defstruct id: nil, nickname: "", kills: 0, deaths: 0

  alias Q3Reporter.Parser.Player

  def connect(players, id) do
    case Enum.find(players, fn player -> player.id == id end) do
      nil ->
        new_player = %Player{id: id}
        [new_player | players]

      _player ->
        players
    end
  end

  def update(players, id, fun) do
    Enum.map(players, fn player ->
      if player.id == id, do: fun.(player), else: player
    end)
  end
end
