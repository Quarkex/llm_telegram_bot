defmodule LLMTelegramBot.Bot do
  @moduledoc """
  This is the main module of the bot.
  It uses the ExGram.Bot behaviour to handle the messages.
  """

  require Logger

  @bot :llm_telegram_bot

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  middleware(ExGram.Middleware.IgnoreUsername)

  @doc """
  This is the entry point for the bot.
  It will be called for every message that is not a command.
  """
  def handle(
        {:text, text, %{chat: %{id: chat_id, username: username}}},
        %{bot_info: %{first_name: bot_name}}
      ) do
    # If we are in the whitelist we can use the bot,
    # then we need to send a message to the user to let them know we are
    # working on it
    with true <- is_whitelisted?(username),
         %{message_id: message_id} <- ExGram.send_message!(chat_id, "💭", bot: @bot) do
      # Spawn a new process to avoid blocking the bot
      spawn(fn ->
        params =
          LLMTelegramBot.get_config()
          |> Enum.map(fn {key, value} ->
            case key do
              :template ->
                {:prompt, OpenAI.prompt(text, template: value, bot_name: bot_name)}

              _ ->
                {key, value}
            end
          end)

        params = params ++ [slot_id: chat_id]

        # This will consume the stream until it ends and return all the chunks joined
        response =
          OpenAI.stream(params)
          |> Enum.to_list()
          |> Enum.join()

        # Update the loading message replacing it with the response
        ExGram.edit_message_text(response, chat_id: chat_id, message_id: message_id, bot: @bot)
      end)
    end
  end

  defp is_whitelisted?(username) do
    case LLMTelegramBot.get_config()[:whitelist] do
      nil ->
        true

      [] ->
        true

      whitelist ->
        Enum.member?(whitelist, username)
    end
  end
end
