defmodule Dependable.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/skoblton/dependable"

  def project do
    [
      app: :dependable,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      source_url: @source_url,
      description: "Lightweight dependency injection using application config"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package() do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp docs() do
    [
      source_ref: @version,
      main: "overview",
      extra_section: "GUIDES",
      formatters: ["html", "epub"],
      extras: ["guides/overview.md"]
    ]
  end
end
