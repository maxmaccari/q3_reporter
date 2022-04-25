defmodule Q3Reporter.Core do
  @moduledoc """
  Module that contains the core logic of the q3_reporter.
  """

  alias Q3Reporter.Core.{Game, Interpreter, Results}

  @type mode :: :by_game | :ranking | nil

  @doc """
  Parse a log content into a `Q3Reporter.Core.Results` structure.

  ## Options
    * `mode` - `:by_game` or `:ranking`. Defaults to `:by_game`.

  ## Example

    iex> Q3Reporter.Core.log_to_results("  0:00 InitGame:")
    %Q3Reporter.Core.Results {
      :mode => :by_game,
      :entries => [ %{game: "Game 1", ranking: [], total_kills: 0} ]
    }
  """
  @spec log_to_results(String.t(), mode) :: Results.t()
  def log_to_results(content, mode \\ :by_game) do
    content
    |> log_to_games()
    |> games_to_results(mode)
  end

  @doc """
  Parse a log content into a list of`Q3Reporter.Core.Game`.

  ## Example

    iex> Q3Reporter.Core.log_to_games("  0:00 InitGame:")
    [ %Q3Reporter.Core.Game{ initialized_at: ~T[00:00:00], players: %{} } ]
  """
  @spec log_to_games(String.t()) :: list(Games.t())
  defdelegate log_to_games(content), to: Interpreter, as: :interpret

  @doc """
  Transform a list of`Q3Reporter.Core.Game` into a `Q3Reporter.Core.Result` structure.

  ## params
    * `mode` - `:by_game` or `:ranking`. Defaults to `:by_game`.

  ## Example

    iex> Q3Reporter.Core.games_to_results([ %Q3Reporter.Core.Game{} ], :by_game)
    %Q3Reporter.Core.Results {
      :mode => :by_game,
      :entries => [ %{game: "Game 1", ranking: [], total_kills: 0} ]
    }
  """
  @spec games_to_results(list(Game.t()), mode) :: Results.t()
  def games_to_results(games, mode \\ :by_game) do
    Results.new(games, mode || :by_game)
  end
end
