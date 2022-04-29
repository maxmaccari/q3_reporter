defmodule Q3Reporter.GameServer.ServerTest do
  use ExUnit.Case, async: true

  alias Q3Reporter.Core.Results
  alias Q3Reporter.GameServer.Server

  import Support.LogHelpers

  @content __DIR__ |> Path.join("../../fixtures/example.log") |> File.read!()

  defp with_log(context) do
    path = create_log()

    push_log(path, @content, NaiveDateTime.new!(2022, 1, 1, 0, 0, 0))

    Map.put(context, :path, path)
  end

  defp with_server(%{path: path} = context) do
    {:ok, _pid} = start_supervised({Server, path: path})

    context
  end

  setup :with_log

  test "should start a server with the correct path", %{path: path} do
    assert {:ok, pid} = start_supervised({Server, path: path})
    assert Process.alive?(pid)
  end

  test "should not start a server with missing path" do
    assert {:error, "path is required"} = Server.start_link()
  end

  @invalid_path "invalid"
  test "should stop if the given path is invalid" do
    assert {:error, :enoent} = Server.start_link(path: @invalid_path)
  end

  test "should stop if the given log is deleted" do
    Process.flag(:trap_exit, true)
    path = create_log()

    assert {:ok, pid} = Server.start_link(path: path)

    assert :ok = Server.subscribe(path, :by_game)

    touch_log(path)

    assert_receive {:game_results, ^path, :by_game, %Results{entries: [], mode: :by_game}}

    delete_log(path)

    assert_receive {:EXIT, ^pid, {:shutdown, {:error, :enoent}}}

    Process.flag(:trap_exit, false)
  end

  describe "with server started" do
    setup [:with_log, :with_server]

    test "should allow to subscribe to a log with :by_game mode", %{path: path} do
      assert :ok = Server.subscribe(path)
      assert Server.subscribed?(path)
      refute Server.subscribed?(path, :ranking)

      touch_log(path)

      assert_receive {:game_results, ^path, :by_game, %Results{entries: [], mode: :by_game}}
    end

    test "should allow to subscribe to a log with :ranking mode", %{path: path} do
      assert :ok = Server.subscribe(path, :ranking)
      assert Server.subscribed?(path, :ranking)
      refute Server.subscribed?(path, :by_game)

      touch_log(path)

      assert_receive {:game_results, ^path, :ranking, %Results{entries: [], mode: :ranking}}
    end

    test "should allow to suscribe :by_game and :by_ranking modes", %{path: path} do
      assert :ok = Server.subscribe(path, :by_game)
      assert :ok = Server.subscribe(path, :ranking)

      assert Server.subscribed?(path, :ranking)
      assert Server.subscribed?(path, :by_game)

      touch_log(path)

      assert_receive {:game_results, ^path, :by_game, %Results{entries: [], mode: :by_game}}
      assert_receive {:game_results, ^path, :ranking, %Results{entries: [], mode: :ranking}}
    end

    test "should allow to unsubscribe by the given mode", %{path: path} do
      assert :ok = Server.subscribe(path, :by_game)
      assert :ok = Server.subscribe(path, :ranking)

      assert Server.unsubscribe(path, :by_game)

      touch_log(path)

      refute_receive {:game_results, ^path, :by_game, %Results{entries: [], mode: :by_game}}
      assert_receive {:game_results, ^path, :ranking, %Results{entries: [], mode: :ranking}}

      assert Server.unsubscribe(path, :ranking)

      touch_log(path)

      refute_receive {:game_results, ^path, :by_game, %Results{entries: [], mode: :by_game}}
      refute_receive {:game_results, ^path, :ranking, %Results{entries: [], mode: :ranking}}
    end

    test "should get current results from path when requisited", %{path: path} do
      assert %Q3Reporter.Core.Results{
               entries: [
                 %{
                   game: "Game 1",
                   ranking: [%{}],
                   total_kills: 0
                 }
               ],
               mode: :by_game
             } = Server.results(path)

      assert %Q3Reporter.Core.Results{
               entries: [%{}],
               mode: :ranking
             } = Server.results(path, :ranking)
    end
  end
end
