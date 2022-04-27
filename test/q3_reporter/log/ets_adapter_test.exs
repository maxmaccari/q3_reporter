defmodule Q3Reporter.Log.ETSAdapterTest do
  use ExUnit.Case

  alias Q3Reporter.Log
  alias Q3Reporter.Log.ETSAdapter

  setup context do
    name = :crypto.strong_rand_bytes(10) |> Base.encode64(padding: false)
    ETSAdapter.push(name, "", NaiveDateTime.new!(2022, 1, 1, 0, 0, 0))

    on_exit(fn ->
      ETSAdapter.close(name)
    end)

    Map.put(context, :name, name)
  end

  test "should read the content of the given log file", %{name: name} do
    assert {:ok, ""} = Log.read(name, ETSAdapter)
    assert {:error, :enoent} = Log.read("noexits", ETSAdapter)
  end

  test "should get the mtime from the given file", %{name: name} do
    expected_mtime = NaiveDateTime.new!(2022, 1, 1, 0, 0, 0)
    new_mtime = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    assert {:ok, ^expected_mtime} = Log.mtime(name, ETSAdapter)

    ETSAdapter.push(name, "", new_mtime)

    assert {:ok, ^new_mtime} = Log.mtime(name, ETSAdapter)
  end
end
