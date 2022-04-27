defmodule Support.LogHelpers do
  alias Q3Reporter.Log.ETSAdapter

  def create_log() do
    name = :crypto.strong_rand_bytes(10) |> Base.encode64(padding: false)
    ETSAdapter.push(name, "", NaiveDateTime.new!(2022, 1, 1, 0, 0, 0))

    name
  end

  def touch_log(name, mtime \\ NaiveDateTime.utc_now()) do
    ETSAdapter.push(name, "", mtime)
  end

  def delete_log(name) do
    ETSAdapter.close(name)
  end
end