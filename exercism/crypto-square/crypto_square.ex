defmodule CryptoSquare do
  @alphabet ~w(a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9)

  @doc """
  Encode string square methods
  ## Examples

    iex> CryptoSquare.encode("abcd")
    "ac bd"
  """
  @spec encode(String.t()) :: String.t()
  def encode(str) do
    str
    |> String.downcase()
    |> String.graphemes()
    |> Enum.filter(&(&1 in @alphabet))
    |> to_square()
  end

  defp to_square([]), do: ""

  defp to_square(crypto) do
    width = crypto |> length() |> :math.sqrt() |> ceil()

    crypto
    |> Enum.chunk_every(width, width, List.duplicate(" ", width))
    |> Enum.zip()
    |> Enum.map_join(" ", &(&1 |> Tuple.to_list() |> to_string()))
  end
end
