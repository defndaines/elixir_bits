defmodule Hamming do
  @doc """
  Returns number of differences between two strands of DNA, known as the Hamming Distance.

  ## Examples

  iex> Hamming.hamming_distance('AAGTCATA', 'TAGCGATC')
  {:ok, 4}
  """
  @spec hamming_distance([char], [char]) :: non_neg_integer
  def hamming_distance(strand1, strand2) do
    distance(String.to_charlist(strand1), String.to_charlist(strand2), 0)
  end

  defp distance([], [], acc), do: {:ok, acc}
  defp distance([], _, _), do: {:error, "Lists must be the same length"}
  defp distance(_, [], _), do: {:error, "Lists must be the same length"}
  defp distance([c | rest_1], [c | rest_2], acc) do
    distance(rest_1, rest_2, acc)
  end
  defp distance([_ | rest_1], [_ | rest_2], acc) do
    distance(rest_1, rest_2, acc + 1)
  end
end
