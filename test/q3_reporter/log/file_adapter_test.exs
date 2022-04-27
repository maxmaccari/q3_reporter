defmodule Q3Reporter.Log.FileAdapterTest do
  use ExUnit.Case, async: false

  alias Q3Reporter.Log
  alias Q3Reporter.Log.FileAdapter

  @example_file Path.join(__DIR__, "./.temp_log")

  def create_example(file \\ @example_file),
    do: File.touch(file, {{2022, 1, 1}, {0, 0, 0}})

  def delete_example(file \\ @example_file), do: File.rm(file)

  setup do
    create_example()

    on_exit(fn ->
      delete_example()
    end)
  end

  test "should read the content of the given log file" do
    assert {:ok, ""} = Log.read(@example_file, FileAdapter)
    assert {:error, :enoent} = Log.read("noexits", FileAdapter)
  end

  test "should get the mtime from the given file" do
    expected_mtime = NaiveDateTime.new!(2022, 1, 1, 0, 0, 0)
    new_mtime = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    assert {:ok, ^expected_mtime} = Log.mtime(@example_file, FileAdapter)

    File.touch(@example_file, NaiveDateTime.to_erl(new_mtime))

    assert {:ok, ^new_mtime} = Log.mtime(@example_file, FileAdapter)
  end
end
