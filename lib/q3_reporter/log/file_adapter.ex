defmodule Q3Reporter.Log.FileAdapter do
  @behaviour Q3Reporter.Log

  @impl true
  def read(path), do: File.read(path)

  @impl true
  def mtime(path) do
    case File.stat(path) do
      {:ok, stat} -> NaiveDateTime.from_erl(stat.mtime)
      {:error, _} = error -> error
    end
  end
end
