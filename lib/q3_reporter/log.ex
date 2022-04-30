defmodule Q3Reporter.Log do
  @moduledoc false

  alias Q3Reporter.Log.FileAdapter

  @type read_return :: {:ok, String.t()} | {:error, atom()}
  @type mtime_return :: {:ok, NaiveDateTime.t()} | {:error, atom()}

  @callback read(String.t()) :: read_return
  @callback mtime(String.t()) :: mtime_return

  @default_adapter Application.compile_env(:q3_reporter, :log_adapter, FileAdapter)

  @spec read(String.t(), atom() | nil) :: read_return()
  def(read(path, adapter \\ @default_adapter))
  def read(path, adapter) when is_nil(adapter), do: @default_adapter.read(path)
  def read(path, adapter), do: adapter.read(path)

  @spec mtime(String.t(), atom() | nil) :: mtime_return()
  def mtime(path, adapter \\ @default_adapter)
  def mtime(path, adapter) when is_nil(adapter), do: @default_adapter.mtime(path)
  def mtime(path, adapter), do: adapter.mtime(path)
end
