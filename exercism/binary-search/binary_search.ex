defmodule BinarySearch do
  @doc """
    Searches for a key in the tuple using the binary search algorithm.
    It returns :not_found if the key is not in the tuple.
    Otherwise returns {:ok, index}.

    ## Examples

      iex> BinarySearch.search({}, 2)
      :not_found

      iex> BinarySearch.search({1, 3, 5}, 2)
      :not_found

      iex> BinarySearch.search({1, 3, 5}, 5)
      {:ok, 2}

  """

  @spec search(tuple, integer) :: {:ok, integer} | :not_found
  def search(numbers, key), do: do_search(numbers, key, 0, tuple_size(numbers) - 1)

  defp do_search(_, _, min, max) when max < min, do: :not_found

  defp do_search(numbers, key, min, max) do
    pos = div(max - min, 2) + min
    value = elem(numbers, pos)

    cond do
      value == key -> {:ok, pos}
      value < key -> do_search(numbers, key, pos + 1, max)
      value > key -> do_search(numbers, key, min, pos - 1)
    end
  end
end
