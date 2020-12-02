defmodule Advent.MixProject do
  use Mix.Project

  def project do
    dirs = 1..25 |> Enum.map(&to_string/1) |> Enum.map(&String.pad_leading(&1, 2, "0"))

    [
      app: :advent,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: dirs,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application, do: [extra_applications: [:logger]]
  defp deps, do: []
end
