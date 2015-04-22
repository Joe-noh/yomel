defmodule Yomel.Parser do
  @on_load {:init, 0}

  def init do
    :erlang.load_nif('priv/yomel', 0)
  end

  defmacrop bye do
    quote do
      exit(:nif_not_loaded)
    end
  end

  def initialize, do: bye
  def input_string(_parser, _str), do: bye
  def next_event(_parser), do: bye

  def event_stream(yaml_string) do
    Stream.resource(es_start_fn(yaml_string), es_next_fn, es_after_fn)
  end

  defp es_start_fn(input) do
    fn -> initialize |> input_string(input) end
  end

  defp es_next_fn do
    fn (parser) ->
      case next_event(parser) do
        :halt -> {:halt, parser}
        event -> {[event], parser}
      end
    end
  end

  defp es_after_fn do
    fn (_parser) -> end
  end
end
