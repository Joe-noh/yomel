defmodule ParserTest do
  use ExUnit.Case

  test "parsing scalar" do
    [scalar] = TestHelper.parse_and_unpack("hello")
    assert scalar == {:scalar, "hello", nil, nil, :plain}
  end
end
