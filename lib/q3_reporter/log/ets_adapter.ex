defmodule Q3Reporter.Log.ETSAdapter do
  @moduledoc """
  Adapter that read content from ETS. Mostly used for testing and debug propuses.
  """

  @behaviour Q3Reporter.Log

  @table __MODULE__

  @doc false
  @impl true
  def read(name) do
    case :ets.lookup(@table, name) do
      [{_name, content, _mtime}] -> {:ok, content}
      _ -> {:error, :enoent}
    end
  end

  @doc false
  @impl true
  def mtime(name) do
    case :ets.lookup(@table, name) do
      [{_name, _content, mtime}] -> {:ok, mtime}
      _ -> {:error, :enoent}
    end
  end

  @doc false
  def init, do: :ets.new(@table, [:named_table, :set, :public])

  @doc false
  def close(name), do: :ets.delete(@table, name)

  @doc false
  def push(name, content \\ "", mtime \\ NaiveDateTime.utc_now()) do
    :ets.insert(@table, {name, content, mtime})
  end
end
