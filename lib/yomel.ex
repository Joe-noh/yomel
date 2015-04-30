defmodule Yomel do
  alias Yomel.Parser
  alias Yomel.Decoder

  def decode(input) do
    input
    |> Parser.parse_string
    |> Decoder.decode
  end

  def decode_file(path) do
    path
    |> File.read!
    |> Parser.parse_string
    |> Decoder.decode
  end
end
