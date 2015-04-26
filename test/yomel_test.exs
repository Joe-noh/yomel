defmodule YomelTest do
  use ExUnit.Case

  test "the truth" do
    input = """
    ---
    receipt:     Oz-Ware Purchase Invoice

    items:
        - part_no:   A4786
          descrip:   'Water Bucket (Filled)'
          price:     1.47

        - part_no:   E1628
          quantity:  !!int 1

    bill_to:  &id001
        street: |
                123 Tornado Alley
                Suite 16
        city:   East Centerville

    ship_to:
        <<:   *id001
        city: Tokyo

    specialDelivery:  >
        Follow the Yellow Brick
        Road to the Emerald City.
        Pay no attention to the
        man behind the curtain.
    ...
    """

    events = Yomel.Parser.event_stream(input) |> Enum.to_list |> IO.inspect

    Yomel.Decoder.decode(events) |> IO.inspect

    assert is_list(events)
    assert Enum.count(events) > 20
    assert [:stream_start, :document_start | _] = events
  end
end
