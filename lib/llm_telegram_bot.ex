defmodule LLMTelegramBot do
  @moduledoc """
  LLMTelegramBot is a Telegram bot that uses OpenAI's API to generate responses to messages.
  """

  @doc """
  Returns the application configuration.
  """
  def get_config() do
    Application.get_env(:llm_telegram_bot, __MODULE__)
    |> Enum.reject(&is_nil(elem(&1, 1)))
    |> Keyword.put_new(:template, nil)
  end

  @doc """
  Returns the application configuration for a given key.
  """
  def get_config(key, default \\ nil),
    do: Application.get_env(:llm_telegram_bot, __MODULE__)[key] || default
end
