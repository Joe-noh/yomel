defmodule Yomel.Parser do
  @on_load {:init, 0}

  def init do
    [__DIR__, ~w[.. .. priv yomel]]
    |> List.flatten
    |> Path.join
    |> String.to_char_list
    |> :erlang.load_nif(0)
  end

  defmacrop nif do
    quote do
      exit(:nif_not_loaded)
    end
  end

  def parse_string(input) do
    input
    |> nif_parse_string
    |> Enum.reverse
  end

  defp nif_parse_string(_input), do: nif
end
