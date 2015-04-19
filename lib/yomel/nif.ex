defmodule Yomel.Nif do
  @on_load {:init, 0}

  def init do
    :erlang.load_nif('priv/yomel', 0)
  end

  defmacrop bye do
    quote do
      exit(:nif_not_loaded)
    end
  end

  def parse_string(_str), do: bye
  def initialize, do: bye
  def input_string(_yaml, _str), do: bye
  def next_event(_yaml), do: bye
end
