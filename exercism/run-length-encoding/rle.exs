defmodule RunLengthEncoder do
  @doc """
  Generates a string where consecutive elements are represented as a data value and count.
  "HORSE" => "1H1O1R1S1E"
  For this example, assume all input are strings, that are all uppercase letters.
  It should also be able to reconstruct the data into its original form.
  "1H1O1R1S1E" => "HORSE"
  """
  @spec encode(String.t()) :: String.t()
  def encode(string) do
    string
    |> String.graphemes()
    |> Enum.chunk_by(& &1)
    |> Enum.reduce("", fn e, acc -> acc <> to_count(e) end)
  end

  defp to_count([c | _] = list) do
    Integer.to_string(length(list)) <> c
  end

  @spec decode(String.t()) :: String.t()
  def decode(string) do
    # WiP
  end
end
