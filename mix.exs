defmodule SpeakEx.Mixfile do
  use Mix.Project

  def project do
    [app: :speak_ex,
     version: "0.0.3",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  def application do
    [applications: [:logger, :erlagi]]
  end

  defp deps do
    [
      {:erlagi, github: "smpallen99/erlagi", branch: "feature/rebar3"},
    ]
  end
end
