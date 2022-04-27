defmodule Q3Reporter.FileWatcher.ServerTest do
  use ExUnit.Case, async: true

  alias Q3Reporter.FileWatcher.Server

  import Support.LogHelpers

  def create_example(context) do
    path = create_log()

    on_exit(fn ->
      delete_log(path)
    end)

    Map.put(context, :path, path)
  end

  def watch_example(context) do
    {:ok, file} = start_supervised({Server, context.path})

    Map.put(context, :watched, file)
  end

  describe "Server.start_link/2" do
    setup :create_example

    test "with a valid file", %{path: path} do
      assert {:ok, pid} = Server.start_link(path)
      assert Process.alive?(pid)
    end

    test "with invalid file" do
      assert {:error, :enoent} = Server.start_link("invalid")
    end
  end

  describe "Server.close/1" do
    setup [:create_example, :watch_example]

    test "close the given file", %{watched: file} do
      Server.close(file)
      refute Process.alive?(file)
    end
  end

  describe "Server.subscribe/1" do
    setup [:create_example, :watch_example]

    test "receive a message when the file change", %{watched: file, path: path} do
      assert :ok = Server.subscribe(file)

      touch_log(path)

      assert_receive {:file_updated, ^file, _mtime}, 200
    end

    test "dont't receive a message when the file doesn't change", %{watched: file} do
      assert :ok = Server.subscribe(file)

      refute_receive {:file_updated, ^file, _mtime}, 200
    end
  end

  describe "Server.unsubscribe/1" do
    setup [:create_example, :watch_example]

    test "receive a message when the file changes", %{watched: file, path: path} do
      assert :ok = Server.subscribe(file)
      assert :ok = Server.unsubscribe(file)

      touch_log(path)

      refute_receive {:file_updated, ^file, _mtime}, 200
    end

    test "receive a message when subscribe again and the file changes", %{
      watched: file,
      path: path
    } do
      assert :ok = Server.subscribe(file)
      assert :ok = Server.unsubscribe(file)
      assert :ok = Server.subscribe(file)

      touch_log(path)

      assert_receive {:file_updated, ^file, _mtime}, 200
    end
  end

  describe "Server.subscribed?/2" do
    setup [:create_example, :watch_example]

    test "check if pid is subscribed to a file", %{watched: file} do
      refute Server.subscribed?(file)

      Server.subscribe(file)

      assert Server.subscribed?(file)
    end

    test "check if pid is unsubscribed if process is not alive", %{watched: file, path: path} do
      task = Task.async(fn -> Server.subscribe(file) end)
      Task.await(task)
      Server.subscribe(file)

      touch_log(path)

      assert_receive {:file_updated, _, _}, 200
      assert Server.subscribed?(file, self())
      refute Server.subscribed?(file, task.pid)
    end
  end
end
