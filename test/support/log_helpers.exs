defmodule Support.LogHelpers do
  alias Q3Reporter.Log.ETSAdapter

  def random_log_path() do
    :crypto.strong_rand_bytes(50) |> Base.url_encode64(padding: false)
  end

  def create_log(name \\ random_log_path()) do
    ETSAdapter.push(name, "", NaiveDateTime.new!(2022, 1, 1, 0, 0, 0))
    name
  end

  def touch_log(name, mtime \\ NaiveDateTime.utc_now()) do
    ETSAdapter.push(name, "", mtime)
  end

  def push_log(name, content, mtime \\ NaiveDateTime.utc_now()) do
    ETSAdapter.push(name, content, mtime)
  end

  def delete_log(name) do
    ETSAdapter.close(name)
  end
end
