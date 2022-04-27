defmodule Q3Reporter.Log.ETSAdapterTest do
  use ExUnit.Case, async: true

  alias Q3Reporter.Log
  alias Q3Reporter.Log.ETSAdapter

  import Support.LogHelpers

  setup context do
    path = random_log_path()
    ETSAdapter.push(path, "", NaiveDateTime.new!(2022, 1, 1, 0, 0, 0))

    on_exit(fn ->
      ETSAdapter.close(path)
    end)

    Map.put(context, :path, path)
  end

  test "should read the content of the given log file", %{path: path} do
    assert {:ok, ""} = Log.read(path, ETSAdapter)
    assert {:error, :enoent} = Log.read("noexits", ETSAdapter)
  end

  test "should get the mtime from the given file", %{path: path} do
    expected_mtime = NaiveDateTime.new!(2022, 1, 1, 0, 0, 0)
    new_mtime = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    assert {:ok, ^expected_mtime} = Log.mtime(path, ETSAdapter)

    ETSAdapter.push(path, "", new_mtime)

    assert {:ok, ^new_mtime} = Log.mtime(path, ETSAdapter)
  end
end
