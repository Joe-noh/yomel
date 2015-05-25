# Yomel

libyaml interface for elixir.

## Usage

### Decoding

```elixir
iex> yaml = """
...> ---
...> number: 100
...> name: John
...> """

iex> Yomel.decode(yaml)
{:ok, [%{"number" => 100, "name" => "John"}]}

iex> Yomel.decode_file("./example.yaml")
```
