defmodule Q3ReporterTest do
  use ExUnit.Case, asyc: true

  alias Q3Reporter
  alias Q3Reporter.Core.Results

  import Support.LogHelpers

  describe "Q3Reporter.parse/2" do
    @content Path.join(__DIR__, "./fixtures/example.log") |> File.read!()

    setup context do
      path = create_log()
      push_log(path, @content)

      on_exit(fn ->
        delete_log(path)
      end)

      Map.put(context, :path, path)
    end

    test "with valid file and default mode", %{path: path} do
      assert {:ok, results} = Q3Reporter.parse(path, mode: :by_game)
      assert %Results{entries: [%{}], mode: :by_game} = results
    end

    test "with valid file and ranking mode", %{path: path} do
      assert {:ok, results} = Q3Reporter.parse(path, mode: :ranking)
      assert %Results{entries: [%{}], mode: :ranking} = results
    end

    test "with invalid file path" do
      assert {:error, _msg} = Q3Reporter.parse("invalid", [])
    end
  end
end
