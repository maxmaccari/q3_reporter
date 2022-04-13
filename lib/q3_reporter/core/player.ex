defmodule Q3Reporter.Core.Player do
  @moduledoc false

  defstruct id: nil, nickname: "", kills: 0, deaths: 0, connected?: false

  @type id :: String.t()
  @type t :: %__MODULE__{
          connected?: boolean(),
          deaths: integer(),
          id: id(),
          kills: integer(),
          nickname: String.t()
        }

  @spec new(id(), String.t(), boolean()) :: t()
  def new(id, nickname \\ "", connected? \\ false) do
    %__MODULE__{
      id: id,
      nickname: nickname,
      connected?: connected?
    }
  end

  @spec set_nickname(t(), String.t()) :: t()
  def set_nickname(%__MODULE__{} = player, nickname) do
    %{player | nickname: nickname}
  end

  @spec connect(t()) :: t()
  def connect(%__MODULE__{} = player), do: %{player | connected?: true}

  @spec disconnect(t()) :: t()
  def disconnect(%__MODULE__{} = player), do: %{player | connected?: false}

  @spec increment_kills(t()) :: t()
  def increment_kills(%__MODULE__{kills: kills} = player) do
    %{player | kills: kills + 1}
  end

  @spec increment_deaths(t()) :: t()
  def increment_deaths(%__MODULE__{deaths: deaths} = player) do
    %{player | deaths: deaths + 1}
  end
end
