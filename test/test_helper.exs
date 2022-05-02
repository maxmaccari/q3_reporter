Code.require_file("support/log_helpers.exs", __DIR__)
Code.require_file("support/error_adapters.exs", __DIR__)
Q3Reporter.Log.ETSAdapter.init()

{:ok, _} = Application.ensure_all_started(:q3_reporter)

ExUnit.start()
