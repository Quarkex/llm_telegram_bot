defmodule LLMTelegramBot.Application do
  use Application

  def start(_type, _args) do
    token = LLMTelegramBot.get_config(:telegram_bot_token, nil)

    children = [
      ExGram,
      {LLMTelegramBot.Bot, [method: :polling, token: token]}
    ]

    opts = [strategy: :one_for_one, name: LLMTelegramBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
