defmodule OpenAI do
  @moduledoc """
  OpenAI is a module that uses OpenAI's API to generate responses to messages.
  """

  require Logger

  @doc """
  Returns a prompt for a given text with the template already applied.
  """
  def prompt(text, opts \\ []) do
    Keyword.get(opts, :template, "User: %{TEXT}\n%{BOT_NAME}: ")
    |> String.replace("%{BOT_NAME}", Keyword.get(opts, :bot_name, "Llama"))
    |> String.replace("%{TEXT}", text)
  end

  @doc """
  Returns a stream of responses to a given prompt.

  ## Examples
      iex> OpenAI.stream(prompt: "Hello, world!")
      ["Hel", "lo,", " user", "!", "How", " are", " you", "?"]
  """
  def stream(opts \\ []) do
    url =
      LLMTelegramBot.get_config(:api_protocol, "http") <>
        "://" <>
        LLMTelegramBot.get_config(:endpoint, "localhost") <>
        LLMTelegramBot.get_config(:api_path, "/completion")

    body = Jason.encode!(body(opts))
    headers = headers()

    Stream.resource(
      fn -> HTTPoison.post!(url, body, headers, stream_to: self(), async: :once) end,
      &handle_async_response/1,
      &close_async_response/1
    )
  end

  defp close_async_response(resp),
    do: :hackney.stop_async(resp)

  defp handle_async_response({:done, resp}),
    do: {:halt, resp}

  defp handle_async_response(%HTTPoison.AsyncResponse{id: id} = resp) do
    receive do
      %HTTPoison.AsyncStatus{id: ^id, code: code} ->
        Logger.info("openai,request,status,#{inspect(code)}")
        HTTPoison.stream_next(resp)
        {[], resp}

      %HTTPoison.AsyncHeaders{id: ^id, headers: headers} ->
        Logger.info("openai,request,headers,#{inspect(headers)}")
        HTTPoison.stream_next(resp)
        {[], resp}

      %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
        HTTPoison.stream_next(resp)
        parse_chunk(chunk, resp)

      %HTTPoison.AsyncEnd{id: ^id} ->
        {:halt, resp}
    end
  end

  defp parse_chunk(chunk, resp) do
    {chunk, done?} =
      chunk
      |> String.split("data:")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
      |> Enum.reduce({"", false}, fn trimmed, {chunk, is_done?} ->
        case Jason.decode(trimmed) do
          {:ok, %{"content" => text}} ->
            {chunk <> text, is_done? or false}

          {:error, %{data: "[DONE]"}} ->
            {chunk, is_done? or true}
        end
      end)

    if done?,
      do: {[chunk], {:done, resp}},
      else: {[chunk], resp}
  end

  defp headers() do
    [
      Accept: "application/json",
      "Content-Type": "application/json",
      Authorization: "Bearer #{LLMTelegramBot.get_config(:openai_api_key, "no-key")}"
    ]
  end

  defp body(opts) do
    %{
      model: LLMTelegramBot.get_config(:model, "LLaMA_CPP"),
      prompt: "",
      temperature: 0.7,
      top_p: 0.5,
      top_k: 40,
      stream: true,
      repeat_penalty: 1.18,
      n_predict: 400,
      stop: ["</s>", "Llama: ", "User: "],
      repeat_last_n: 256,
      tfs_z: 1,
      typical_p: 1,
      presence_penalty: 0,
      frequency_penalty: 0,
      mirostat: 0,
      mirostat_tau: 5,
      mirostat_eta: 0.1,
      grammar: "",
      n_probs: 0,
      image_data: [],
      cache_prompt: true,
      slot_id: -1
    }
    |> Enum.map(fn {key, default_value} ->
      {"#{key}", Keyword.get(opts, key, default_value)}
    end)
    |> Map.new()
  end
end
