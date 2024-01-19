import Config

config :llm_telegram_bot, LLMTelegramBot,
  whitelist: System.get_env("WHITELIST", "") |> String.split(","),
  endpoint: System.get_env("ENDPOINT", "localhost"),
  api_path: System.get_env("API_PATH", "/completion"),
  api_protocol: System.get_env("API_PROTOCOL", "http"),
  openai_api_key: System.get_env("OPENAI_API_KEY", "no-key"),
  telegram_bot_token: System.get_env("TELEGRAM_BOT_TOKEN", nil),
  model: System.get_env("MODEL", "LLaMA_CPP"),
  template:
    System.get_env(
      "TEMPLATE",
      "This is a conversation between User and %{BOT_NAME}, a friendly chatbot. %{BOT_NAME} is helpful, kind, honest, good at writing, and never fails to answer any requests immediately and with precision.\n\nUser: %{TEXT}\n%{BOT_NAME}: "
    ),
  temperature: String.to_float(System.get_env("TEMPERATURE", "0.7")),
  top_p: String.to_float(System.get_env("TOP_P", "0.5")),
  top_k: String.to_integer(System.get_env("TOP_K", "40")),
  stream: System.get_env("STREAM", "true") == "true" || System.get_env("STREAM") == "1",
  repeat_penalty: String.to_float(System.get_env("REPEAT_PENALTY", "1.18")),
  n_predict: String.to_integer(System.get_env("N_PREDICT", "400")),
  stop: System.get_env("STOP", "</s>;Llama: ;User: ") |> String.split(";"),
  repeat_last_n: String.to_integer(System.get_env("REPEAT_LAST_N", "256")),
  tfs_z: String.to_integer(System.get_env("TFS_Z", "1")),
  typical_p: String.to_integer(System.get_env("TYPICAL_P", "1")),
  presence_penalty: String.to_integer(System.get_env("PRESENCE_PENALTY", "0")),
  frequency_penalty: String.to_integer(System.get_env("FREQUENCY_PENALTY", "0")),
  mirostat: String.to_integer(System.get_env("MIROSTAT", "0")),
  mirostat_tau: String.to_integer(System.get_env("MIROSTAT_TAU", "5")),
  mirostat_eta: String.to_float(System.get_env("MIROSTAT_ETA", "0.1")),
  grammar: System.get_env("GRAMMAR", ""),
  n_probs: String.to_integer(System.get_env("N_PROBS", "0")),
  image_data: System.get_env("IMAGE_DATA", "") |> String.split(";"),
  cache_prompt:
    System.get_env("CACHE_PROMPT", "true") == "true" || System.get_env("CACHE_PROMPT") == "1",
  slot_id: String.to_integer(System.get_env("SLOT_ID", "-1"))
