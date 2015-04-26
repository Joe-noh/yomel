defmodule ParserTest do
  use ExUnit.Case
  import TestHelper

  test "parsing scalar" do
    actual = parse_and_unpack("hello")
    expected = [{:scalar, "hello", nil, nil, :plain}]
    assert actual == expected
  end

  test "parsing sequence" do
    actual = parse_and_unpack("- 1")
    expected = [
      {:sequence_start, nil, nil, :block},
      {:scalar, "1", nil, nil, :plain},
      :sequence_end
    ]
    assert actual == expected
  end

  test "parsing mapping" do
    actual = parse_and_unpack("key: val")
    expected = [
      {:mapping_start, nil, nil, :block},
      {:scalar, "key", nil, nil, :plain},
      {:scalar, "val", nil, nil, :plain},
      :mapping_end
    ]
    assert actual == expected
  end

  test "parsing sequence of mappings" do
    actual = parse_and_unpack("""
    ---
    - key1: val1
    - key2: val2
    """)
    expected = [
      {:sequence_start, nil, nil, :block},
      {:mapping_start, nil, nil, :block},
      {:scalar, "key1", nil, nil, :plain},
      {:scalar, "val1", nil, nil, :plain},
      :mapping_end,
      {:mapping_start, nil, nil, :block},
      {:scalar, "key2", nil, nil, :plain},
      {:scalar, "val2", nil, nil, :plain},
      :mapping_end,
      :sequence_end
    ]

    assert actual == expected
  end

  test "parsing mapping including sequences" do
    actual = parse_and_unpack("""
    ---
    key:
      - 1
      - 2
    """)
    expected = [
      {:mapping_start, nil, nil, :block},
      {:scalar, "key", nil, nil, :plain},
      {:sequence_start, nil, nil, :block},
      {:scalar, "1", nil, nil, :plain},
      {:scalar, "2", nil, nil, :plain},
      :sequence_end,
      :mapping_end
    ]

    assert actual == expected
  end

  test "parsing several documents" do
    expected = [
      :stream_start,
      :document_start,
      {:scalar, "", nil, nil, :plain},
      :document_end,
      :document_start,
      {:scalar, "", nil, nil, :plain},
      :document_end,
      :stream_end
    ]
    actual = Yomel.Parser.parse_string("---\n---\n")

    assert actual == expected
  end

  test "parsing empty document" do
    expected = [:stream_start, :stream_end]
    assert Yomel.Parser.parse_string("") == expected
  end
end
