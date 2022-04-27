defmodule Q3ReporterTest do
  use ExUnit.Case, asyc: true

  alias Q3Reporter
  alias Q3Reporter.Core.Results

  alias Q3Reporter.Log.FileAdapter

  describe "Q3Reporter.parse/2" do
    @path Path.join(__DIR__, "./fixtures/example.log")

    test "with valid file and default mode" do
      assert {:ok, results} = Q3Reporter.parse(@path, mode: :by_game, log_adapter: FileAdapter)
      assert %Results{entries: [%{}], mode: :by_game} = results
    end

    test "with valid file and ranking mode" do
      assert {:ok, results} = Q3Reporter.parse(@path, mode: :ranking, log_adapter: FileAdapter)
      assert %Results{entries: [%{}], mode: :ranking} = results
    end

    test "with invalid file path" do
      assert {:error, _msg} = Q3Reporter.parse("invalid", log_adapter: FileAdapter)
    end
  end
end
