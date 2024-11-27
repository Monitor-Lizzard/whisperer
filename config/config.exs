import Config

config :whisperer,
  llm_model: "gpt-3.5-turbo"

import_config "#{config_env()}.exs"
