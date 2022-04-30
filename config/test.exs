import Config

config :q3_reporter, Q3Reporter.ModifyChecker, timeout: 10
config :q3_reporter, log_adapter: Q3Reporter.Log.ETSAdapter
