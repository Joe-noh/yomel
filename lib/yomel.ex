defmodule Yomel do
  alias Yomel.Parser
  alias Yomel.Decoder

  @doc ~S"""
  Decodes yaml string into Elixir term.

      iex> Yomel.decode "[1, 2, 3]"
      {:ok, [[1, 2, 3]]}

      iex> Yomel.decode "a: 1\nb: 2"
      {:ok, [%{"a" => 1, "b" => 2}]}
  """
  @spec decode(String.t) :: {:ok, [term]}
  def decode(input) do
    input
    |> Parser.parse_string
    |> Decoder.decode
  end

  @doc ~S"""
  Docodes the yaml written in given file into Elixir term.

      iex> Yomel.decode_file "./example.com"
      {:ok, [%{"a" => 1, "b" => 2}]}
  """
  @spec decode_file(String.t) :: {:ok, [term]}
  def decode_file(path) do
    path
    |> File.read!
    |> Parser.parse_string
    |> Decoder.decode
  end
end
