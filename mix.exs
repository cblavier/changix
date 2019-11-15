defmodule Changix.MixProject do
  use Mix.Project

  def project do
    [
      app: :changix,
      name: "Changix",
      description: "Elixir library that gives you changelog features based on markdown files.",
      source_url: "https://github.com/cblavier/changix",
      version: "0.3.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: [
        main: "Changix",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:earmark, "~> 1.4.2", runtime: false, optional: true}
    ]
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* priv),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/cblavier/changix"}
    ]
  end
end
