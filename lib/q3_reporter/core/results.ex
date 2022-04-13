defmodule Q3Reporter.Core.Results do
  alias Q3Reporter.Core.Game

  defstruct entries: [], type: nil

  @type entry :: %{
          nickname: String.t(),
          kills: integer(),
          deaths: integer()
        }

  @type game :: %{
          game: String.t(),
          ranking: list(entry()),
          total_kills: integer()
        }

  @type t :: %__MODULE__{
          type: :by_game | :general,
          entries: list(entry | game)
        }

  defp new(entries, type) when type in [:by_game, :general] do
    %__MODULE__{
      entries: entries,
      type: type
    }
  end

  @spec by_game(list(Game.t())) :: t()
  def by_game(games) do
    games
    |> Enum.with_index()
    |> Enum.map(fn {game, index} ->
      %{
        game: "Game #{index + 1}",
        ranking: game |> Game.list_players() |> build_ranking(),
        total_kills: Game.total_kills(game)
      }
    end)
    |> new(:by_game)
  end

  @spec general(list(Game.t())) :: t()
  def general(games) do
    games
    |> Enum.map(&Game.list_players/1)
    |> List.flatten()
    |> build_ranking()
    |> new(:general)
  end

  defp build_ranking(players) do
    players
    |> Enum.reduce(%{}, &update_ranking/2)
    |> Map.to_list()
    |> Enum.map(fn {nickname, {kills, deaths}} ->
      %{nickname: nickname, kills: kills, deaths: deaths}
    end)
    |> Enum.sort(&sort_rankings/2)
  end

  defp update_ranking(player, ranking) do
    Map.update(
      ranking,
      player.nickname,
      {player.kills, player.deaths},
      &update_stats(&1, player.kills, player.deaths)
    )
  end

  defp update_stats({player_kills, player_deaths}, inc_kills, inc_deaths) do
    {player_kills + inc_kills, player_deaths + inc_deaths}
  end

  defp sort_rankings(%{kills: kills} = r1, %{kills: kills} = r2), do: r1.deaths < r2.deaths

  defp sort_rankings(r1, r2), do: r1.kills > r2.kills

  defimpl String.Chars, for: __MODULE__ do
    alias Q3Reporter.Core.Results

    def to_string(%Results{entries: entries, type: :general}) do
      "# General Ranking #\n" <> ranking_text(entries)
    end

    def to_string(%Results{entries: [], type: :by_game}), do: "# No Games :( #"

    def to_string(%Results{entries: entries, type: :by_game}) do
      entries
      |> Enum.map(&"# #{&1.game} #\n#{ranking_text(&1.ranking)}\nTotal Kills: #{&1.total_kills}")
      |> Enum.join("\n\n")
    end

    defp ranking_text([]), do: "--- Empty ---"

    defp ranking_text(entries) do
      entries
      |> Enum.map(&"#{&1.nickname}: #{&1.kills} kills / #{&1.deaths} deaths")
      |> Enum.join("\n")
    end
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    alias Q3Reporter.Core.Results

    def encode(%Results{entries: entries}, opts) do
      Jason.Encode.list(entries, opts)
    end
  end
end
