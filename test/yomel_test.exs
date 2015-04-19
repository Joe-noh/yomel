defmodule YomelTest do
  use ExUnit.Case

  test "the truth" do
    Yomel.Nif.initialize
    |> Yomel.Nif.input_string("key: 3")
    |> Yomel.Nif.next_event
    |> IO.inspect
  end
end
