defmodule Yomel.Decoder do
  defmodule Yaml do
    defstruct events: [], anchors: %{}
  end

  alias Yaml, as: Y

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

  defp decode_document(docs, %Y{events: [:stream_end]}), do: docs

  defp decode_document(docs, yaml) do
    case do_decode(yaml) do
      {:doc_end, yaml} -> decode_document(docs, yaml)
      {doc, yaml} -> decode_document([doc | docs], yaml)
      :halt -> Enum.reverse docs  # decoding finished
    end
  end

  @doc "decode a document"
  @doc false
  @spec do_decode(%Y{}) :: {yaml_doc, %Y{}} | {:doc_end, %Y{}} | :halt
  defp do_decode(yaml)

  defp do_decode(yaml = %Y{events: [{:mapping_start, anchor, tag, _} | rest],
                           anchors: anchors}) do
    {map, yaml} = decode_map(%Y{yaml | events: rest}, tag)
    case anchor do
      nil    -> {map, yaml}
      anchor -> {map, %Y{yaml | anchors: Map.put_new(anchors, anchor, map)}}
    end
  end

  defp do_decode(yaml = %Y{events: [{:sequence_start, anchor, tag, _style} | rest],
                           anchors: anchors}) do
    {seq, yaml} = decode_seq(%Y{yaml | events: rest}, tag)
  end

  defp do_decode(yaml = %Y{events: [{:scalar, value, tag, anchor, _style} | rest]}) do
    {value, %Y{yaml | events: rest}}
  end

  defp do_decode(yaml = %Y{events: [{:alias, anchor} | rest], anchors: anchors}) do
    {Map.get(anchors, anchor), %Y{yaml | events: rest}}
  end

  defp do_decode(yaml = %Y{events: [:document_end | rest]}) do
    {:doc_end, %Y{yaml | events: rest}}
  end

  defp do_decode(yaml = %Y{events: [:stream_end]}), do: :halt

  defp decode_map(yaml, tag) do
    do_decode_map(yaml, %{})
  end

  defp do_decode_map(yaml = %Y{events: [:mapping_end | rest]}, acc) do
    {acc, %Y{yaml | events: rest}}
  end

  defp do_decode_map(yaml = %Y{events: events}, acc) do
    {key, yaml} = do_decode(yaml)
    {val, yaml} = do_decode(yaml)

    case key do
      "<<" -> do_decode_map(yaml, Map.merge(val, acc))
      _    -> do_decode_map(yaml, Map.put(acc, key, val))
    end
  end

  defp decode_seq(yaml, tag) do
    do_decode_seq(yaml, [])
  end

  defp do_decode_seq(yaml = %Y{events: [:sequence_end | rest]}, acc) do
    {acc, %Y{yaml | events: rest}}
  end

  defp do_decode_seq(yaml, acc) do
    {elem, yaml} = do_decode(yaml)
    do_decode_seq(yaml, [elem | acc])
  end
end
