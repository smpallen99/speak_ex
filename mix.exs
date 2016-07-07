defmodule SpeakEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :speak_ex,
      version: "0.3.0",
      elixir: "~> 1.3",
      deps: deps,
      package: package,
      name: "Coherence",
      description: """
      An Elixir framework for building telephony applications, inspired by Ruby's Adhearsion.
      """]
  end

  def application do
    [applications: [:logger, :erlagi]]
  end

  defp deps do
    [
      {:erlagi, github: "smpallen99/erlagi"},
      {:ex_ami, "~> 0.1"},
    ]
  end

  defp package do
    [ maintainers: ["Stephen Pallen"],
      licenses: ["MIT"],
      links: %{ "Github" => "https://github.com/smpallen99/speak_ex"},
      files: ~w(lib README.md mix.exs LICENSE)]
  end
end
