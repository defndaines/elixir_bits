defmodule GameOfLife do
  @doc """
  Apply the rules of Conway's Game of Life to a grid of cells
  """

  @spec tick(matrix :: list(list(0 | 1))) :: list(list(0 | 1))
  def tick([]), do: []

  def tick(matrix) do
    step = do_tick(matrix)

    for x <- 0..(length(matrix) - 1) do
      for y <- 0..(length(hd(matrix)) - 1), do: Map.get(step, {x, y})
    end
  end

  defp do_tick(matrix) do
    map = to_map(matrix)

    Enum.reduce(map, %{}, fn {pos, live}, acc ->
      Map.put(acc, pos, alive(live, neighbors(map, pos)))
    end)
  end

  defp to_map(matrix) do
    matrix
    |> Enum.with_index(fn row, x -> Enum.with_index(row, fn live, y -> {{x, y}, live} end) end)
    |> List.flatten()
    |> Map.new()
  end

  defp alive(1, neighbors) when neighbors in 2..3, do: 1
  defp alive(0, 3), do: 1
  defp alive(_, _), do: 0

  defp neighbors(map, {x, y}) do
    for(
      m <- (x - 1)..(x + 1),
      n <- (y - 1)..(y + 1),
      {m, n} != {x, y},
      do: Map.get(map, {m, n}, 0)
    )
    |> Enum.sum()
  end
end
