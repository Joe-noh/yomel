ExUnit.start()

defmodule TestHelper do
  alias Yomel.Parser

  def parse_and_unpack(string) do
    [:stream_start, :document_start | rest] = Parser.parse_string(string)
    [:stream_end, :document_end | content] = Enum.reverse(rest)
    Enum.reverse content
  end
end
