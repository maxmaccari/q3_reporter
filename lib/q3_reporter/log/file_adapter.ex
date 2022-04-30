defmodule Q3Reporter.Log.FileAdapter do
  @moduledoc """
  Adapter that read content from File. This is the default adapter that is set.
  """

  @behaviour Q3Reporter.Log

  @doc false
  @impl true
  def read(path), do: File.read(path)

  @doc false
  @impl true
  def mtime(path) do
    case File.stat(path) do
      {:ok, stat} -> NaiveDateTime.from_erl(stat.mtime)
      {:error, _} = error -> error
    end
  end
end
