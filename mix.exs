defmodule Whisperer.MixProject do
  use Mix.Project

  def project do
    [
      app: :whisperer,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:langchain, "0.3.0-rc.0"}
    ]
  end
end
