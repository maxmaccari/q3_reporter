defmodule Q3Reporter.LogParser do
  alias Q3Reporter.Core
  alias Q3Reporter.Core.Results

  @spec parse(String.t(), Results.mode() | nil) :: {:ok, Results.t()} | {:error, String.t()}
  def parse(path, mode) do
    with {:ok, content} <- File.read(path),
         results <- Core.interpret_log(content, mode: mode) do
      {:ok, results}
    else
      {:error, :enoent} -> {:error, "'#{path}' not found..."}
      {:error, :eacces} -> {:error, "You don't have permission to open '#{path}..."}
      {:error, :enomem} -> {:error, "There's not enough memory to open '#{path}..."}
      {:error, _} -> {:error, "Error trying to open '#{path}'"}
    end
  end
end
