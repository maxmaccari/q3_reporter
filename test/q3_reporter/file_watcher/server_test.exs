defmodule Q3Reporter.FileWatcher.ServerTest do
  use ExUnit.Case, async: false

  alias Q3Reporter.FileWatcher.Server

  @example_file Path.join(__DIR__, "./.temp_log")

  defp create_example,
    do: File.touch(@example_file, {{2022, 1, 1}, {0, 0, 0}})

  defp touch_example, do: File.touch(@example_file)
  defp delete_example, do: File.rm(@example_file)

  def start_server(context) do
    create_example()

    on_exit(fn ->
      delete_example()
    end)

    {:ok, file} = start_supervised({Server, [@example_file]})

    Map.put(context, :watched, file)
  end

  describe "Server.start_link/2" do
    @valid_path Path.join(__DIR__, "../../fixtures/example.log")

    test "with a valid file" do
      assert {:ok, pid} = Server.start_link(@valid_path)
      assert Process.alive?(pid)
    end

    test "with invalid file" do
      assert {:error, :enoent} = Server.start_link("invalid")
    end
  end

  describe "Server.close/1" do
    setup :start_server

    test "close the given file", %{watched: file} do
      Server.close(file)
      refute Process.alive?(file)
    end
  end

  describe "Server.subscribe/1" do
    setup :start_server

    test "receive a message when the file change", %{watched: file} do
      assert :ok = Server.subscribe(file)

      touch_example()

      assert_receive {:file_updated, ^file, _mtime}, 200
    end

    test "dont't receive a message when the file doesn't change", %{watched: file} do
      assert :ok = Server.subscribe(file)

      refute_receive {:file_updated, ^file, _mtime}, 200
    end
  end

  describe "Server.unsubscribe/1" do
    setup :start_server

    test "receive a message when the file changes", %{watched: file} do
      assert :ok = Server.subscribe(file)
      assert :ok = Server.unsubscribe(file)

      touch_example()

      refute_receive {:file_updated, ^file, _mtime}, 200
    end

    test "receive a message when subscribe again and the file changes", %{watched: file} do
      assert :ok = Server.subscribe(file)
      assert :ok = Server.unsubscribe(file)
      assert :ok = Server.subscribe(file)

      touch_example()

      assert_receive {:file_updated, ^file, _mtime}, 200
    end
  end

  describe "Server.subscribed?/2" do
    setup :start_server

    test "check if pid is subscribed to a file", %{watched: file} do
      refute Server.subscribed?(file)

      Server.subscribe(file)

      assert Server.subscribed?(file)
    end

    test "check if pid is unsubscribed if process is not alive", %{watched: file} do
      task = Task.async(fn -> Server.subscribe(file) end)
      Task.await(task)
      Server.subscribe(file)

      touch_example()

      assert_receive {:file_updated, _, _}, 200
      assert Server.subscribed?(file, self())
      refute Server.subscribed?(file, task.pid)
    end
  end
end
