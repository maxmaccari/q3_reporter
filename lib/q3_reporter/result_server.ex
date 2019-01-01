defmodule Q3Reporter.ResultServer do
  use Agent

  @name :result_server

  def start_link(result) do
    Agent.start_link(fn -> result end, name: @name)
  end

  def get_result do
    Agent.get(@name, fn result -> result end)
  end

  def update_result(new_result) do
    Agent.update(@name, fn _ -> new_result end)
  end
end
