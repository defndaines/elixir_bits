defmodule PascalsTriangle do
  @doc """
  Calculates the rows of a pascal triangle
  with the given height
  """
  @spec rows(integer) :: [[integer]]
  def rows(num) do
    Enum.take(Stream.iterate([1], &next/1), num)
  end

  @spec next([[integer]]) :: [[integer]]
  defp next(row) do
    Enum.zip_with([[0 | row], row ++ [0]], fn [x, y] -> x + y end)
  end
end
