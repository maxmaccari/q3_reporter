defmodule Q3Reporter.CoreTest do
  use ExUnit.Case
  alias Q3Reporter.Core
  alias Q3Reporter.Core.{Results, Game}

  describe "Core.interpret_log/2" do
    @content " 12:00 InitGame:\n 12:00 ShutdownGame:"

    test "with default mode" do
      assert %Results{entries: [%{}], type: :by_game} = Core.interpret_log(@content)
    end

    test "with ranking mode" do
      assert %Results{entries: [%{}], type: :by_game} = Core.interpret_log(@content)
    end
  end
end
