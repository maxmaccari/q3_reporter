defmodule Q3Reporter.Core.Interpreter.LineInterpreter do
  use ExUnit.Case

  alias Q3Reporter.Core.Interpreter.Parser

  describe "LineInterpreter.parse_line/1" do
    test "12:00 InitGame:" do
      assert Parser.parse_line(" 12:00 InitGame:") == {:init_game, Time.new!(12, 0, 0)}
      assert Parser.parse_line(" 18:35 InitGame:") == {:init_game, Time.new!(18, 35, 0)}
    end

    test "12:00 ShutdownGame:" do
      assert Parser.parse_line(" 12:00 ShutdownGame:") == {:shutdown_game, Time.new!(12, 0, 0)}
      assert Parser.parse_line(" 18:35 ShutdownGame:") == {:shutdown_game, Time.new!(18, 35, 0)}
    end

    test "12:00 ClientConnect: #playerId" do
      assert Parser.parse_line(" 12:00 ClientConnect: 1") == {:client_connect, "1"}
      assert Parser.parse_line(" 12:00 ClientConnect: 2") == {:client_connect, "2"}
    end

    test "12:00 ClientDisconnect: #playerId" do
      assert Parser.parse_line(" 12:00 ClientDisconnect: 1") == {:client_disconnect, "1"}
      assert Parser.parse_line(" 12:00 ClientDisconnect: 2") == {:client_disconnect, "2"}
    end

    test "12:00 ClientBegin: #playerId" do
      assert Parser.parse_line(" 12:00 ClientBegin: 1") == {:client_begin, "1"}
      assert Parser.parse_line(" 12:00 ClientBegin: 2") == {:client_begin, "2"}
    end

    test "12:00 ClientUserinfoChanged: <info_metadata>" do
      assert Parser.parse_line(~S( 12:00 ClientUserinfoChanged: 1 n\Dono da Bola\t#ignored#)) ==
               {:client_nickname_changed, "1", "Dono da Bola"}

      assert Parser.parse_line(~S( 12:00 ClientUserinfoChanged: 2 n\Mocinha\t#ignored#)) ==
               {:client_nickname_changed, "2", "Mocinha"}
    end

    test "12:00 Kill: <player_kill>" do
      assert Parser.parse_line(~S( 12:00 Kill: 1 2 6:#ignored#)) ==
               {:kill, "1", "2"}

      assert Parser.parse_line(~S( 12:00 Kill: 2 1 6:#ignored#)) ==
               {:kill, "2", "1"}
    end

    test "12:00 Kill: <world_kill>" do
      assert Parser.parse_line(~S( 12:00 Kill: 1022 1 6:#ignored#)) ==
               {:kill, :world, "1"}

      assert Parser.parse_line(~S( 12:00 Kill: 1022 2 6:#ignored#)) ==
               {:kill, :world, "2"}
    end

    test "invalid line" do
      assert Parser.parse_line("12:00 InitGame:") == :ignore
      assert Parser.parse_line("12:00 ShutdownGame:") == :ignore
      assert Parser.parse_line("Totaly Invalid Line") == :ignore
    end
  end
end
