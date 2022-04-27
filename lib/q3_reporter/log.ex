defmodule Q3Reporter.Log do
  @moduledoc false

  alias Q3Reporter.Log.FileAdapter

  @callback read(String.t()) :: {:ok, String.t()} | {:error, atom()}
  @callback mtime(String.t()) :: {:ok, NaiveDateTime.t()} | {:error, atom()}

  @default_adapter Application.compile_env(:q3_reporter, :log_adapter, FileAdapter)

  def read(path, adapter \\ @default_adapter)
  def read(path, adapter) when is_nil(adapter), do: @default_adapter.read(path)
  def read(path, adapter), do: adapter.read(path)

  def mtime(path, adapter \\ @default_adapter)
  def mtime(path, adapter) when is_nil(adapter), do: @default_adapter.mtime(path)
  def mtime(path, adapter), do: adapter.mtime(path)
end
