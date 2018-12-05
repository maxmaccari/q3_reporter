defmodule Q3ReporterTest do
  use ExUnit.Case
  doctest Q3Reporter

  test "greets the world" do
    assert Q3Reporter.hello() == :world
  end
end
