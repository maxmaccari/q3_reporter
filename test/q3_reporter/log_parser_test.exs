defmodule Q3Reporter.LogParserTest do
  use ExUnit.Case
  alias Q3Reporter.LogParser
  alias Q3Reporter.Core.Results

  describe "LogParserTest.parse/2" do
    @path Path.join(__DIR__, "../fixtures/example.log")

    test "with valid file and default mode" do
      assert {:ok, results} = LogParser.parse(@path, mode: :by_game)
      assert %Results{entries: [%{}], mode: :by_game} = results
    end

    test "with valid file and ranking mode" do
      assert {:ok, results} = LogParser.parse(@path, mode: :ranking)
      assert %Results{entries: [%{}], mode: :ranking} = results
    end

    test "with invalid file path" do
      assert {:error, _msg} = LogParser.parse("invalid", [])
    end
  end
end
