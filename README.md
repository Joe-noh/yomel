# Yomel

libyaml interface for elixir.

## Usage

Currently this only supports decoding.

```elixir
yaml = """
---
number: 100
name: John
"""

Yomel.decode(yaml) #=> {:ok, [%{"number" => 100, "name" => "John"}]}

Yomel.decode_file("./example.yaml")
```
