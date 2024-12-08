defmodule Whisperer.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :whisperer,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: docs(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      name: "Whisperer",
      description: """
      Whisperer provides an unopinionated approach for running multiple agents in Elixir
      """,
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Whisperer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end

  defp aliases do
    [
      lint: ["format --check-formatted", "credo --strict"]
    ]
  end

  defp docs do
    [
      main: "Whisperer",
      source_url: "https://github.com/Monitor-Lizzard/whisperer",
      extra_section: "GUIDES",
      extras: [
        {"README.md", [title: "Whisperer"]},
        {"CHANGELOG.md", [title: "Changelog"]},
        {"LICENSE.md", [title: "License"]}
      ],
      groups_for_modules: [
        Agent: [
          Whisperer.Agent
        ],
        Sequencer: [
          Whisperer.Sequence,
          Whisperer.Sequencer
        ],
        Orchestrator: [
          Whisperer.Orchestrator
        ]
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Oluwapelumi Sola-Aremu", "Otun Ridwan Adeola"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Monitor-Lizzard/whisperer"},
      keywords: [
        "AI",
        "Agents",
        "AI Agents",
        "Multi-Agent Systems",
        "LLM",
        "Language Models",
        "NLP",
        "Task Orchestration",
        "Workflow Automation"
      ],
      categories: [
        "Machine Learning",
        "Agents",
        "Artificial Intelligence",
        "Natural Language Processing",
        "Automation"
      ]
    ]
  end
end
