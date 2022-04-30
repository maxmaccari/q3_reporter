defmodule Q3ReporterCli.CliTest do
  use ExUnit.Case, async: true

  alias Q3ReporterCli.Cli

  import ExUnit.CaptureIO
  import Support.LogHelpers

  @content Path.join(__DIR__, "../fixtures/example.log") |> File.read!()

  setup_all context do
    path = create_log("test/fixtures/example.log")
    push_log(path, @content)

    on_exit(fn ->
      delete_log(path)
    end)

    Map.put(context, :path, path)
  end

  test "show help when send invalid params" do
    assert capture_io(:stderr, fn ->
             Cli.main()
           end) ==
             """
             usage: q3_reporter [options] <filename>

             Options:
               --ranking => Output ranking instead summary
               --json => Output result as json

             """
  end

  test "show error when give a file that doesn't exist" do
    assert capture_io(:stderr, fn ->
             Cli.main(["noexists"])
           end) == "'noexists' not found...\n"
  end

  test "parse a file normally" do
    assert capture_io(fn ->
             Cli.main(["test/fixtures/example.log"])
           end) == """
           # Game 1 #
           Isgalamido: 0 kills / 0 deaths
           Total Kills: 0
           """
  end

  test "parse a file and print in json format" do
    assert capture_io(fn ->
             Cli.main(["--json", "test/fixtures/example.log"])
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
             Cli.main(["--ranking", "test/fixtures/example.log"])
           end) == """
           # General Ranking #
           Isgalamido: 0 kills / 0 deaths
           """
  end

  test "parse a file with ranking option in json format" do
    assert capture_io(fn ->
             Cli.main(["--ranking", "--json", "test/fixtures/example.log"])
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
