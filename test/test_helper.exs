ExUnit.start()

defmodule TestHelper do
  alias Yomel.Parser

  @doc """
  parse given string into libyaml events,
  then strip preceding :stream_start and :document_start and
  succeeding :document_end and :stream_end off.
  """
  def parse_and_unpack(string) do
    [:stream_start, :document_start | rest] = Parser.parse_string(string)
    [:stream_end, :document_end | content] = Enum.reverse(rest)
    Enum.reverse content
  end

  @doc """
  prepend :stream_start and :document_start and append :document_end and
  :stream_end to given list of events.
  """
  def pack(events) do
    [:stream_start, :document_start | events] ++ [:document_end, :stream_end]
  end
end
