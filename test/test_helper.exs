Code.require_file("support/log_helpers.exs", __DIR__)
Q3Reporter.Log.ETSAdapter.init()

Application.ensure_started(:q3_reporter)

ExUnit.start()
