defmodule Mix.Tasks.Compile.Yaml do
  @shortdoc "Compiles libyaml"

  def run(_) do
    # TODO: Totally untested
    if match? {:win32, _}, :os.type do
      raise RuntimeError, message: "Compiling on windows is not currently supported"
    else
      {result, _error_code} = System.cmd("make", ["priv/yomel.so"], stderr_to_stdout: true)
      IO.binwrite result
      :ok
    end
  end
end

defmodule Yomel.Mixfile do
  use Mix.Project

  def project do
    [app: :yomel,
     version: "0.3.0",
     elixir: "~> 1.2.0",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:yaml, :elixir, :app],
     deps: deps,
     docs: docs]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:earmark, "~> 0.2", only: :dev},
     {:ex_doc,  "~> 0.11", only: :dev},
     {:yaml, github: "yaml/libyaml", tag: "0.1.4", app: false, compile: "./bootstrap && ./configure"}]
  end

  defp description do
    "Decodes yaml into elixir terms"
  end

  defp package do
    [files: ["lib", "c_src", "mix.exs", "Makefile", "README*", "LICENSE*"],
     maintainers: ["Joe Honzawa"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/Joe-noh/yomel"
     }]
  end

  defp docs do
    [readme: "README.md", main: "README"]
  end
end
