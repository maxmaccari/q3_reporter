defmodule Q3Reporter.LogTest do
  use ExUnit.Case, async: false

  alias Q3Reporter.Log
  alias Q3Reporter.Log.ETSAdapter

  import Support.LogHelpers

  setup context do
    path = random_log_path()
    ETSAdapter.push(path, "", NaiveDateTime.new!(2022, 1, 1, 0, 0, 0))

    Map.put(context, :path, path)
  end

  test "should use the given adapter", %{path: path} do
    assert {:ok, ""} = Log.read(path, ETSAdapter)
    assert {:ok, _mtime} = Log.mtime(path, ETSAdapter)
  end

  test "should use default adapter if missing or nil", %{path: path} do
    assert {:ok, ""} = Log.read(path)
    assert {:ok, ""} = Log.read(path, nil)

    assert {:ok, _mtime} = Log.mtime(path)
    assert {:ok, _mtime} = Log.mtime(path, nil)
  end
end
