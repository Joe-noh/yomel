defmodule Mix.Tasks.Compile.Nif do
  use Mix.Task

  @shortdoc "compile c_src/*.c"

  @compiler "clang"
  @erl_flag "-I#{:code.root_dir}/erts-#{:erlang.system_info :version}/include"
  @c_files  Path.wildcard("c_src/*.c")
  @out_opt  "-o priv/yomel.so"

  def run(_) do
    File.mkdir_p!("priv")

    [@compiler, @erl_flag, @c_files, shared_opts, @out_opt]
    |> List.flatten
    |> Enum.join(" ")
    |> Mix.shell.cmd
  end

  defp shared_opts, do: ["-shared" | os_shared_opts]

  defp os_shared_opts do
    case :os.type do
      {:unix, :darwin} -> ~w(-dynamiclib -undefined dynamic_lookup -lyaml)
      _other -> []
    end
  end
end

defmodule Yomel.Mixfile do
  use Mix.Project

  def project do
    [app: :yomel,
     version: "0.2.0",
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
    [files: ["lib", "priv", "c_src", "mix.exs", "README*", "LICENSE*"],
     contributors: ["Joe Honzawa"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/Joe-noh/yomel"
     }]
  end

  defp docs do
    [readme: "README.md", main: "README"]
  end
end
