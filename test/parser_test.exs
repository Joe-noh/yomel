defmodule ParserTest do
  use ExUnit.Case
  import TestHelper

  test "parsing scalar" do
    actual = parse_and_unpack("hello")
    expected = [{:scalar, "hello", nil, nil, :plain}]
    assert actual == expected
  end

  test "parsing int tagged scalar" do
    actual = parse_and_unpack("!!int 3")
    expected = [{:scalar, "3", nil, "tag:yaml.org,2002:int", :plain}]
    assert actual == expected
  end

  test "parsing str tagged scalar" do
    actual = parse_and_unpack("!!str 3")
    expected = [{:scalar, "3", nil, "tag:yaml.org,2002:str", :plain}]
    assert actual == expected
  end

  test "parsing float tagged scalar" do
    actual = parse_and_unpack("!!float 3")
    expected = [{:scalar, "3", nil, "tag:yaml.org,2002:float", :plain}]
    assert actual == expected
  end

  test "parsing seq tagged sequence" do
    actual = parse_and_unpack("!!seq [1]")
    expected = [
      {:sequence_start, nil, "tag:yaml.org,2002:seq", :flow},
      {:scalar, "1", nil, nil, :plain},
      :sequence_end
    ]
    assert actual == expected
  end

  test "parsing map tagged mapping" do
    actual = parse_and_unpack("!!map {k: v}")
    expected = [
      {:mapping_start, nil, "tag:yaml.org,2002:map", :flow},
      {:scalar, "k", nil, nil, :plain},
      {:scalar, "v", nil, nil, :plain},
      :mapping_end
    ]
    assert actual == expected
  end

  test "parsing sequence" do
    actual = parse_and_unpack("- a")
    expected = [
      {:sequence_start, nil, nil, :block},
      {:scalar, "a", nil, nil, :plain},
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
      - a
      - b
    """)
    expected = [
      {:mapping_start, nil, nil, :block},
      {:scalar, "key", nil, nil, :plain},
      {:sequence_start, nil, nil, :block},
      {:scalar, "a", nil, nil, :plain},
      {:scalar, "b", nil, nil, :plain},
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
