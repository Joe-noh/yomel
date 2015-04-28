defmodule Yomel.TypeConverter do
  @moduledoc """
  convert type of given value based on yaml tag
  """

  @spec convert(String.t, String.t | nil) :: String.t | integer | float
  def convert(val, tag)

  def convert(val, nil), do: val
  def convert(val, "tag:yaml.org,2002:str"), do: val
  def convert(val, "tag:yaml.org,2002:int"), do: String.to_integer(val)
  def convert(val, "tag:yaml.org,2002:float") do
    if String.contains?(val, ".") do
      String.to_float(val)
    else
      String.to_float(val <> ".0")
    end
  end
end
