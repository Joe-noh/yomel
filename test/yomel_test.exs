defmodule YomelTest do
  use ExUnit.Case

  test "the truth" do
    input = """
    ---
    invoice: 34843
    date   : 2001-01-23
    bill-to: &id001
        given  : Chris
        family : Dumars
        address:
            lines: |
                458 Walkman Dr.
                Suite #292
            city    : Royal Oak
            state   : MI
            postal  : 48046
    ship-to: *id001
    product:
        - sku         : BL394D
          quantity    : 4
          description : Basketball
          price       : 450.00
        - sku         : BL4438H
          quantity    : 1
          description : Super Hoop
          price       : 2392.00
    tax  : 251.42
    total: 4443.52
    comments: >
        Late afternoon is best.
        Backup contact is Nancy
        Billsmer @ 338-4338.
    """
    bill_to = %{
      "given" => "Chris",
      "family" => "Dumars",
      "address" => %{
        "lines" => "458 Walkman Dr.\nSuite #292\n",
        "city" => "Royal Oak",
        "state" => "MI",
        "postal" => "48046"
      }
    }

    expected = [%{
      "invoice" => "34843",
      "date" => "2001-01-23",
      "bill-to" => bill_to,
      "ship-to" => bill_to,
      "product" => [
        %{"sku"         => "BL394D",
          "quantity"    => "4",
          "description" => "Basketball",
          "price"       => "450.00"},
        %{"sku"         => "BL4438H",
          "quantity"    => "1",
          "description" => "Super Hoop",
          "price"       => "2392.00"}],
      "tax"  => "251.42",
      "total" => "4443.52",
      "comments" => "Late afternoon is best. Backup contact is Nancy Billsmer @ 338-4338.\n"
    }]

    {:ok, yaml} = Yomel.decode(input)

    assert yaml == expected
  end
end
