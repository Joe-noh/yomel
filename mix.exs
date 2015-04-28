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
     version: "0.1.0",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:nif | Mix.compilers],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    []
  end
end
