defmodule RailFenceCipher do
  @doc """
  Encode a given plaintext to the corresponding rail fence ciphertext
  """
  @spec encode(String.t(), pos_integer) :: String.t()
  def encode(str, rails) do
    Stream.cycle(Range.to_list(1..rails) ++ Range.to_list((rails - 1)..2//-1))
    |> Enum.zip(String.graphemes(str))
    |> Enum.sort_by(fn {n, _} -> n end)
    |> Enum.map_join("", fn {_, ch} -> ch end)
  end

  @doc """
  Decode a given rail fence ciphertext to the corresponding plaintext
  """
  @spec decode(String.t(), pos_integer) :: String.t()
  def decode(str, rails) do
    if String.length(str) < rails do
      str
    else
      Stream.cycle(Range.to_list(1..rails) ++ Range.to_list((rails - 1)..2//-1))
      |> Enum.zip(1..String.length(str))
      |> Enum.sort_by(fn {pos, _} -> pos end)
      |> Enum.zip(String.graphemes(str))
      |> Enum.sort_by(fn {{_, at}, _} -> at end)
      |> Enum.map_join("", fn {_, ch} -> ch end)
    end
  end
end
