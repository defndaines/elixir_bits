defmodule KillerSudokuHelper do
  @doc """
  Return the possible combinations of `size` distinct numbers from 1-9 excluding `exclude` that sum up to `sum`.
  """
  @spec combinations(cage :: %{exclude: [integer], size: integer, sum: integer}) :: [[integer]]
  def combinations(cage) do
    valid = for n <- 1..min(9, cage.sum), n not in cage.exclude, do: n

    cage.size
    |> combinations(valid)
    |> Enum.filter(&(Enum.sum(&1) == cage.sum))
  end

  defp combinations(0, _), do: [[]]
  defp combinations(_, []), do: []

  defp combinations(size, [h | t]) do
    for(l <- combinations(size - 1, t), do: [h | l]) ++ combinations(size, t)
  end
end
