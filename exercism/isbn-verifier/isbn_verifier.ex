defmodule IsbnVerifier do
  @invalid -1

  @doc """
    Checks if a string is a valid ISBN-10 identifier

    ## Examples

      iex> IsbnVerifier.isbn?("3-598-21507-X")
      true

      iex> IsbnVerifier.isbn?("3-598-2K507-0")
      false

  """
  @spec isbn?(String.t()) :: boolean
  def isbn?(isbn) do
    0 == checksum(isbn, 10, 0)
  end

  defguardp is_digit?(ch) when ch in ?0..?9

  defp checksum("", 0, acc), do: rem(acc, 11)
  defp checksum("", _, _), do: @invalid
  defp checksum("X", 1, acc), do: rem(acc + 10, 11)
  defp checksum(<<?-, rest::binary>>, x, acc), do: checksum(rest, x, acc)

  defp checksum(<<ch, rest::binary>>, x, acc) when is_digit?(ch) do
    checksum(rest, x - 1, acc + x * (ch - ?0))
  end

  defp checksum(_, _, _), do: @invalid
end
