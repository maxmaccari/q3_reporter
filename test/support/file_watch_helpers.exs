defmodule Support.FileWatchHelpers do
  @example_file "./.temp_log"

  def example_path(path \\ Path.join(__DIR__, @example_file)), do: path

  def create_example(file \\ Path.join(__DIR__, @example_file)),
    do: File.touch(file, {{2022, 1, 1}, {0, 0, 0}})

  def touch_example(file \\ Path.join(__DIR__, @example_file)), do: File.touch(file)
  def delete_example(file \\ Path.join(__DIR__, @example_file)), do: File.rm(file)
end
