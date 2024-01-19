# LLM Telegram Bot

This project uses ExGram to expose a OpenAI compatible endpoint to a Telegram
bot.

It's main purpose is to allow users to use Telegram as an interface for a
Llamafile server, but it's highly configurable by environment variables.

## docker-compose.yml

If you wish to run this in a container alongside a llamafile, here is a
template docker-compose file to get you started.

This uses the base image `debian:latest` which does not include the openssl
library required by ExGram. In this example we provide the required library in
a deb package and install it on the start command.

It expects to find these required files in the "assets" folder, alter them as
needed:

  - llm_telegram_bot/ (a mix release of this project)
  - [mixtral-8x7b-instruct-v0.1.Q5_K_M.llamafile](https://huggingface.co/jartine/Mixtral-8x7B-Instruct-v0.1-llamafile/resolve/main/mixtral-8x7b-instruct-v0.1.Q5_K_M.llamafile?download=true)
  - [libssl1.1_1.1.1n-0+deb10u3_amd64.deb](https://debian.pkgs.org/10/debian-main-amd64/libssl1.1_1.1.1n-0+deb10u3_amd64.deb.html)

It also expect to have a "COMPOSE_PROJECT_NAME" variable setted that should be
unique. You can configure this and other environment variables using a .env
file.

```
version: '3.7'
  services:
    llamafile:
      image: debian:latest
      command: "bash -c 'dpkg -i libssl.deb && (/model.llamafile --log-disable --port 80 --host 0.0.0.0 --nobrowser & /opt/llm_telegram_bot/bin/llm_telegram_bot start)'"
      restart: unless-stopped
      container_name: ${COMPOSE_PROJECT_NAME}
      tty: true
      env_file:
        - .env
      environment:
        - TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
        - WHITELIST=${WHITELIST}
      volumes:
        - ./assets/mixtral-8x7b-instruct-v0.1.Q5_K_M.llamafile:/model.llamafile:ro
        - ./assets/llm_telegram_bot:/opt/llm_telegram_bot:ro
        - ./assets/libssl1.1_1.1.1n-0+deb10u3_amd64.deb:/libssl.deb:ro
```

## Environment variables:
  An exhaustive list of the available environment variables and their default values.
  The "TELEGRAM_BOT_TOKEN" variable is required. The whitelist is
  case-sensitive, and is ignored if empty.

  - WHITELIST: []
  - ENDPOINT: "localhost"
  - API_PATH: "/completion"
  - API_PROTOCOL: "http"
  - OPENAI_API_KEY: "no-key"
  - TELEGRAM_BOT_TOKEN: nil
  - MODEL: "LLaMA_CPP"
  - TEMPLATE: "This is a conversation between User and %{BOT_NAME}, a friendly chatbot. %{BOT_NAME} is helpful, kind, honest, good at writing, and never fails to answer any requests immediately and with precision.\n\nUser: %{TEXT}\n%{BOT_NAME}: "
  - TEMPERATURE: "0.7"
  - TOP_P: "0.5"
  - TOP_K: "40"
  - STREAM: "true"
  - REPEAT_PENALTY: "1.18"
  - N_PREDICT: "400"
  - STOP: "</s>;Llama: ;User: "
  - REPEAT_LAST_N: "256"
  - TFS_Z: "1"
  - TYPICAL_P: "1"
  - PRESENCE_PENALTY: "0"
  - FREQUENCY_PENALTY: "0"
  - MIROSTAT: "0"
  - MIROSTAT_TAU: "5"
  - MIROSTAT_ETA: "0.1"
  - GRAMMAR: ""
  - N_PROBS: "0"
  - IMAGE_DATA: ""
  - CACHE_PROMPT: "true"
  - SLOT_ID: "-1"
