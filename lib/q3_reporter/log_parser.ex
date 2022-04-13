defmodule Q3Reporter.LogParser do
  alias Q3Reporter.Core

  @spec parse(String.t(), Core.opts() | nil) :: {:ok, Results.t()} | {:error, String.t()}
  def parse(path, opts \\ []) do
    with {:ok, content} <- File.read(path),
         results <- Core.interpret_log(content, opts) do
      {:ok, results}
    else
      {:error, :enoent} -> {:error, "'#{path}' not found..."}
      # coveralls-ignore-start
      {:error, :eacces} -> {:error, "You don't have permission to open '#{path}..."}
      {:error, :enomem} -> {:error, "There's not enough memory to open '#{path}..."}
      {:error, _} -> {:error, "Error trying to open '#{path}'"}
      # coveralls-ignore-stop
    end
  end
end
