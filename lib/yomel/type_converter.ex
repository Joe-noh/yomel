defmodule Yomel.TypeConverter do
  @moduledoc """
  convert type of given value based on yaml tag
  """

  @spec convert(String.t, String.t | nil) :: String.t | integer | float
  def convert(str, tag)

  def convert(str, nil), do: guess(str)
  def convert(str, "tag:yaml.org,2002:str"), do: str
  def convert(str, "tag:yaml.org,2002:int"), do: String.to_integer(str)
  def convert(str, "tag:yaml.org,2002:float") do
    if String.contains?(str, ".") do
      String.to_float(str)
    else
      String.to_float(str <> ".0")
    end
  end

  defp guess(str) do
    cond do
      str =~ ~r/\A\-?((0\.\d+)|([1-9]\d*\.\d+))\z/ -> String.to_float(str)
      str =~ ~r/\A\-?\d+\z/ -> String.to_integer(str)
      true -> str
    end
  end
end
