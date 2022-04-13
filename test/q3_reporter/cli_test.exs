defmodule Q3Reporter.CliTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias Q3Reporter.Cli

  test "show help when send invalid params" do
    assert capture_io(:stderr, fn ->
             Cli.main()
           end) ==
             """
             usage: q3_reporter [options] <filename>

             Options:
               --ranking => Output ranking instead summary
               --json => Output result as json
               --web => Start a webserver with ranking and game summary\n
             """
  end

  test "show error when give a file that doesn't exist" do
    assert capture_io(:stderr, fn ->
             Cli.main(["noexists"])
           end) == "'noexists' not found...\n"
  end

  test "parse a file normally" do
    assert capture_io(fn ->
             Cli.main(["priv/examples/game1.log"])
           end) == """
           # Game 1 #
           Isgalamido: 0 kills / 0 deaths
           Total Kills: 0
           """
  end

  test "parse a file and print in json format" do
    assert capture_io(fn ->
             Cli.main(["--json", "priv/examples/game1.log"])
           end) == """
           [
             {
               "game": "Game 1",
               "ranking": [
                 {
                   "deaths": 0,
                   "kills": 0,
                   "nickname": "Isgalamido"
                 }
               ],
               "total_kills": 0
             }
           ]
           """
  end

  test "parse a file with ranking option" do
    assert capture_io(fn ->
             Cli.main(["--ranking", "priv/examples/game1.log"])
           end) == """
           # General Ranking #
           Isgalamido: 0 kills / 0 deaths
           """
  end

  test "parse a file with ranking option in json format" do
    assert capture_io(fn ->
             Cli.main(["--ranking", "--json", "priv/examples/game1.log"])
           end) ==
             """
             [
               {
                 "deaths": 0,
                 "kills": 0,
                 "nickname": "Isgalamido"
               }
             ]
             """
  end
end
