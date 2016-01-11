defmodule Mix.Tasks.Compile.Nif do
  use Mix.Task

  @shortdoc "compile C source"

  def run(_) do
    if match? {:win32, _}, :os.type do
      raise RuntimeError, message: "Windows is not currently supported"
    else
      {result, _error_code} = System.cmd("make", ["priv/yomel.so"], stderr_to_stdout: true)
      IO.binwrite result
    end

    :ok
  end
end

defmodule Yomel.Mixfile do
  use Mix.Project

  def project do
    [app: :yomel,
     version: "0.4.0",
     elixir: "~> 1.0",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:nif | Mix.compilers],
     deps: deps,
     docs: docs]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:ex_doc,  "~> 0.7", only: :dev}]
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
