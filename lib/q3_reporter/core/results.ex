defmodule Q3Reporter.Core.Results do
  @moduledoc """
  Struct that handle the results of the q3_reporter.
  """

  alias Q3Reporter.Core.Game

  defstruct entries: [], mode: nil

  @type mode :: :by_game | :ranking

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
          mode: mode(),
          entries: list(entry | game)
        }

  @doc false
  @spec new(list(Game.t()), mode() | nil) :: t()
  def new(games, :ranking) do
    %__MODULE__{
      entries: ranking_entries(games),
      mode: :ranking
    }
  end

  def new(games, :by_game) do
    %__MODULE__{
      entries: by_game_entries(games),
      mode: :by_game
    }
  end

  def new(games, _), do: new(games, :by_game)

  defp by_game_entries(games) do
    games
    |> Enum.with_index()
    |> Enum.map(fn {game, index} ->
      %{
        game: "Game #{index + 1}",
        ranking: game |> Game.list_players() |> build_ranking(),
        total_kills: Game.total_kills(game)
      }
    end)
  end

  defp ranking_entries(games) do
    games
    |> Enum.map(&Game.list_players/1)
    |> List.flatten()
    |> build_ranking()
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

  @doc """
  Convert results to string format.
  """
  @spec to_string(t()) :: String.t()
  def to_string(%__MODULE__{entries: entries, mode: :ranking}) do
    "# General Ranking #\n" <> ranking_text(entries)
  end

  def to_string(%__MODULE__{entries: [], mode: :by_game}), do: "# No Games :( #"

  def to_string(%__MODULE__{entries: entries, mode: :by_game}) do
    Enum.map_join(
      entries,
      "\n\n",
      &"# #{&1.game} #\n#{ranking_text(&1.ranking)}\nTotal Kills: #{&1.total_kills}"
    )
  end

  defp ranking_text([]), do: "--- Empty ---"

  defp ranking_text(entries) do
    Enum.map_join(entries, "\n", &"#{&1.nickname}: #{&1.kills} kills / #{&1.deaths} deaths")
  end

  defimpl String.Chars, for: __MODULE__ do
    alias Q3Reporter.Core.Results

    def to_string(results), do: Results.to_string(results)
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    alias Jason.Encode
    alias Q3Reporter.Core.Results

    def encode(%Results{entries: entries}, opts) do
      Encode.list(entries, opts)
    end
  end
end
