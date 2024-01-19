defmodule LLMTelegramBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :llm_telegram_bot,
      version: "0.1.0",
      elixir: "~> 1.15-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison],
      mod: {LLMTelegramBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 2.2.1"},
      {:ex_gram, "~> 0.20.0"},
      {:tesla, "~> 1.2"},
      {:hackney, "~> 1.12"},
      {:jason, ">= 1.0.0"}
    ]
  end
end
