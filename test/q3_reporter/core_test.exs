defmodule Q3Reporter.CoreTest do
  use ExUnit.Case
  alias Q3Reporter.Core
  alias Q3Reporter.Core.Results

  describe "Core.interpret_log/2" do
    @content " 12:00 InitGame:\n 12:00 ClientConnect: 2\n 12:00 ShutdownGame:"

    test "with default mode" do
      assert %Results{entries: [%{}], mode: :by_game} =
               Core.interpret_log(@content, mode: :by_game)
    end

    test "with ranking mode" do
      assert %Results{entries: [%{}], mode: :ranking} =
               Core.interpret_log(@content, mode: :ranking)
    end
  end
end
