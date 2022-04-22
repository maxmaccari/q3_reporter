defmodule Q3Reporter.FileWatcher.SupervisorTest do
  use ExUnit.Case

  alias Q3Reporter.FileWatcher

  @example_file Path.join(__DIR__, "./.temp_log")

  defp create_example,
    do: File.touch(@example_file, {{2022, 1, 1}, {0, 0, 0}})

  defp touch_example, do: File.touch(@example_file)
  defp delete_example, do: File.rm(@example_file)

  describe "FileWatcher.Supervisor" do
    setup context do
      create_example()

      FileWatcher.start_link()

      on_exit(fn ->
        delete_example()
      end)

      Map.put(context, :path, @example_file)
    end

    test "start_child/1 start Server with the file path", %{path: path} do
      assert {:ok, file} = FileWatcher.start_child(path)
      assert Process.alive?(file)
    end
  end
end
