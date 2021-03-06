defmodule Q3Reporter.CliTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  # doctest Q3Reporter

  test "try to parse without specify parameters" do
    assert capture_io(fn ->
             Q3Reporter.Cli.main()
           end) ==
             """
             usage: q3_reporter [options] <filename>

             Options:
               --ranking => Output ranking instead summary
               --json => Output result as json
               --web => Start a webserver with ranking and game summary\n
             """
  end

  test "try to parse inexistent file" do
    assert capture_io(fn ->
             Q3Reporter.Cli.main(["noexists"])
           end) == "'noexists' not found...\n"
  end

  test "try to parse and print a file with one game" do
    assert capture_io(fn ->
             Q3Reporter.Cli.main(["priv/examples/game1.log"])
           end) == """
             Game 1:
               - Isgalamido:
                 Kills: 0
                 Deaths: 0
               => Total Kills: 0

           """
  end

  test "try to parse and print a file with two games" do
    assert capture_io(fn ->
             Q3Reporter.Cli.main(["priv/examples/game2.log"])
           end) == """
             Game 2:
               - Mocinha:
                 Kills: 0
                 Deaths: 1
               - Isgalamido:
                 Kills: -5
                 Deaths: 10
               => Total Kills: 11

             Game 1:
               - Isgalamido:
                 Kills: 0
                 Deaths: 0
               => Total Kills: 0

           """
  end

  test "try to parse and print a file with three games" do
    assert capture_io(fn ->
             Q3Reporter.Cli.main(["priv/examples/game3.log"])
           end) == """
             Game 3:
               - Zeh:
                 Kills: -2
                 Deaths: 2
               - Isgalamido:
                 Kills: 1
                 Deaths: 0
               - Dono da Bola:
                 Kills: -1
                 Deaths: 2
               => Total Kills: 4

             Game 2:
               - Mocinha:
                 Kills: 0
                 Deaths: 1
               - Isgalamido:
                 Kills: -5
                 Deaths: 10
               => Total Kills: 11

             Game 1:
               - Isgalamido:
                 Kills: 0
                 Deaths: 0
               => Total Kills: 0

           """
  end

  test "parse a file and print in json format" do
    assert capture_io(fn ->
             Q3Reporter.Cli.main(["--json", "priv/examples/game3.log"])
           end) == """
           {
             "game1": {
               "Isgalamido": {
                 "deaths": 0,
                 "kills": 0
               },
               "totalKills": 0
             },
             "game2": {
               "Isgalamido": {
                 "deaths": 10,
                 "kills": -5
               },
               "Mocinha": {
                 "deaths": 1,
                 "kills": 0
               },
               "totalKills": 11
             },
             "game3": {
               "Dono da Bola": {
                 "deaths": 2,
                 "kills": -1
               },
               "Isgalamido": {
                 "deaths": 0,
                 "kills": 1
               },
               "Zeh": {
                 "deaths": 2,
                 "kills": -2
               },
               "totalKills": 4
             }
           }
           """
  end

  test "parse a file and print it ranking" do
    assert capture_io(fn ->
             Q3Reporter.Cli.main(["--ranking", "priv/examples/game3.log"])
           end) == """
             Mocinha => 0
             Dono da Bola => -1
             Zeh => -2
             Isgalamido => -4
           """
  end

  test "parse a file and print its ranking in json format" do
    assert capture_io(fn ->
             Q3Reporter.Cli.main(["--ranking", "--json", "priv/examples/game3.log"])
           end) ==
             """
             {
               "ranking": [
                 {
                   "kills": 0,
                   "nickname": "Mocinha"
                 },
                 {
                   "kills": -1,
                   "nickname": "Dono da Bola"
                 },
                 {
                   "kills": -2,
                   "nickname": "Zeh"
                 },
                 {
                   "kills": -4,
                   "nickname": "Isgalamido"
                 }
               ]
             }
             """
  end
end
