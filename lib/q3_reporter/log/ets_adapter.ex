defmodule Q3Reporter.Log.ETSAdapter do
  @behaviour Q3Reporter.Log

  @table __MODULE__

  @impl true
  def read(name) do
    case :ets.lookup(@table, name) do
      [{_name, content, _mtime}] -> {:ok, content}
      _ -> {:error, :enoent}
    end
  end

  @impl true
  def mtime(name) do
    case :ets.lookup(@table, name) do
      [{_name, _content, mtime}] -> {:ok, mtime}
      _ -> {:error, :enoent}
    end
  end

  def init(), do: :ets.new(@table, [:named_table, :set, :public])
  def close(), do: :ets.delete(@table)

  def push(name, content \\ "", mtime \\ NaiveDateTime.utc_now()) do
    :ets.insert(@table, {name, content, mtime})
  end
end
