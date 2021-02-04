defmodule QcloudCosSts.MixProject do
  use Mix.Project

  @github_url "https://github.com/scottming/qcloud_cos_sts"

  def project do
    [
      app: :qcloud_cos_sts,
      description: "An Elixir implementation of the Qcloud COS temporary key.",
      version: "0.1.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        files: ~w(mix.exs lib LICENSE* README.md CHANGELOG.md),
        licenses: ["MIT"],
        maintainers: ["ScottMing"],
        links: %{
          "GitHub" => @github_url
        }
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {QcloudCosSts.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"}
    ]
  end
end
