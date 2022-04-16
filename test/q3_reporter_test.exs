defmodule Q3ReporterTest do
  use ExUnit.Case

  alias Q3Reporter
  alias Q3Reporter.Core.Results

  describe "Q3Reporter.parse/2" do
    @path Path.join(__DIR__, "./fixtures/example.log")

    test "with valid file and default mode" do
      assert {:ok, results} = Q3Reporter.parse(@path, mode: :by_game)
      assert %Results{entries: [%{}], mode: :by_game} = results
    end

    test "with valid file and ranking mode" do
      assert {:ok, results} = Q3Reporter.parse(@path, mode: :ranking)
      assert %Results{entries: [%{}], mode: :ranking} = results
    end

    test "with invalid file path" do
      assert {:error, _msg} = Q3Reporter.parse("invalid", [])
    end
  end
end
