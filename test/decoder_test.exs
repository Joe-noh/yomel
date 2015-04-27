defmodule DecoderTest do
  use ExUnit.Case
  import TestHelper

  test "decoding sequence events" do
    events = pack [
      {:sequence_start, nil, nil, :block},
      {:scalar, "a", nil, nil, :plain},
      {:scalar, "b", nil, nil, :plain},
      :sequence_end
    ]
    {:ok, actual} = Yomel.Decoder.decode(events)
    expected = [["a", "b"]]

    assert actual == expected
  end

  test "decoding mapping events" do
    events = pack [
      {:mapping_start, nil, nil, :block},
      {:scalar, "k", nil, nil, :plain},
      {:scalar, "v", nil, nil, :plain},
      :mapping_end
    ]
    {:ok, actual} = Yomel.Decoder.decode(events)
    expected = [%{"k" => "v"}]

    assert actual == expected
  end

  test "decoding multi-docs events" do
    events = [
      :stream_start,
      :document_start,
      {:scalar, "doc1", nil, nil, :plain},
      :document_end,
      :document_start,
      {:scalar, "doc2", nil, nil, :plain},
      :document_end,
      :stream_end
    ]
    {:ok, actual} = Yomel.Decoder.decode(events)
    expected = ["doc1", "doc2"]

    assert actual == expected
  end

  test "decoding empty doc events" do
    events = pack [{:scalar, "", nil, nil, :plain}]
    {:ok, actual} = Yomel.Decoder.decode(events)
    expected = [""]

    assert actual == expected
  end
end
