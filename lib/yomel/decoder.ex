defmodule Yomel.Decoder do
  defmodule Yaml do
    defstruct events: [], anchors: %{}
  end

  alias Yaml, as: Y
  alias Yomel.TypeConverter, as: Converter

  @type yaml_doc :: term
  @type yaml_event :: term

  @spec decode([term]) :: {:ok, term}
  def decode(events) do
    [:stream_start | rest] = events
    {:ok, decode_stream(%Y{events: rest})}
  end

  @spec decode_stream(%Y{}) :: [yaml_doc]
  defp decode_stream(yaml = %Y{events: [:document_start | rest]}) do
    decode_document(%Y{yaml | events: rest})
  end

  @doc "decode some documents"
  @doc false
  @spec decode_document(%Y{}) :: [yaml_doc]
  defp decode_document(yaml), do: decode_document([], yaml)

  defp decode_document(docs, %Y{events: [:stream_end]}) do
    Enum.reverse docs
  end

  defp decode_document(docs, yaml) do
    case do_decode(yaml) do
      {:doc_end, yaml} -> decode_document(docs, yaml)
      {doc, yaml} -> decode_document([doc | docs], yaml)
    end
  end

  @doc "decode a document"
  @doc false
  @spec do_decode(%Y{}) :: {yaml_doc, %Y{}} | {:doc_end, %Y{}}
  defp do_decode(yaml)

  defp do_decode(yaml = %Y{events: [:document_start | rest]}) do
    do_decode(%Y{yaml | events: rest})
  end

  defp do_decode(yaml = %Y{events: [{:mapping_start, anchor, tag, _} | rest],
                           anchors: anchors}) do
    {map, yaml} = decode_map(%Y{yaml | events: rest}, tag)
    case anchor do
      nil    -> {map, yaml}
      anchor -> {map, %Y{yaml | anchors: Map.put_new(anchors, anchor, map)}}
    end
  end

  defp do_decode(yaml = %Y{events: [{:sequence_start, _anchor, tag, _style} | rest]}) do
    decode_seq(%Y{yaml | events: rest}, tag)
  end

  defp do_decode(yaml = %Y{events: [{:scalar, value, _anchor, tag, _style} | rest]}) do
    {Converter.convert(value, tag), %Y{yaml | events: rest}}
  end

  defp do_decode(yaml = %Y{events: [{:alias, anchor} | rest], anchors: anchors}) do
    {Map.get(anchors, anchor), %Y{yaml | events: rest}}
  end

  defp do_decode(yaml = %Y{events: [:document_end | rest]}) do
    {:doc_end, %Y{yaml | events: rest}}
  end

  defp decode_map(yaml, _tag) do
    do_decode_map(yaml, %{})
  end

  defp do_decode_map(yaml = %Y{events: [:mapping_end | rest]}, acc) do
    {acc, %Y{yaml | events: rest}}
  end

  defp do_decode_map(yaml = %Y{}, acc) do
    {key, yaml} = do_decode(yaml)
    {val, yaml} = do_decode(yaml)

    case key do
      "<<" -> do_decode_map(yaml, Map.merge(val, acc))
      _    -> do_decode_map(yaml, Map.put(acc, key, val))
    end
  end

  defp decode_seq(yaml, _tag) do
    do_decode_seq(yaml, [])
  end

  defp do_decode_seq(yaml = %Y{events: [:sequence_end | rest]}, acc) do
    {Enum.reverse(acc), %Y{yaml | events: rest}}
  end

  defp do_decode_seq(yaml, acc) do
    {elem, yaml} = do_decode(yaml)
    do_decode_seq(yaml, [elem | acc])
  end
end
