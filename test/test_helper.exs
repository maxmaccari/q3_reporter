Code.require_file("support/file_watch_helpers.exs", __DIR__)
Code.require_file("support/log_helpers.exs", __DIR__)
Q3Reporter.Log.ETSAdapter.init()

ExUnit.start()
