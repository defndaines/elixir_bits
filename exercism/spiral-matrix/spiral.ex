defmodule Spiral do
  @doc """
  Given the dimension, return a square matrix of numbers in clockwise spiral order.
  """
  @spec matrix(dimension :: integer) :: list(list(integer))
  def matrix(0), do: []

  def matrix(dimension) do
    goal = dimension ** 2

    open =
      for(x <- 1..dimension, y <- 1..dimension, do: {x, y}, into: MapSet.new())
      |> MapSet.delete({1, 1})

    {nil, spiral} =
      Enum.reduce(1..goal, {{{1, 1}, :east, open}, %{}}, fn e, {{pos, dir, positions}, acc} ->
        state = if not Enum.empty?(positions), do: move(pos, dir, positions)
        {state, Map.put_new(acc, pos, e)}
      end)

    for y <- 1..dimension, do: for(x <- 1..dimension, do: Map.get(spiral, {x, y}))
  end

  defp move(pos, dir, positions) do
    new_pos = step(pos, dir)

    if Enum.member?(positions, new_pos) do
      {new_pos, dir, MapSet.delete(positions, new_pos)}
    else
      move(pos, turn(dir), positions)
    end
  end

  defp step({x, y}, :east), do: {x + 1, y}
  defp step({x, y}, :west), do: {x - 1, y}
  defp step({x, y}, :south), do: {x, y + 1}
  defp step({x, y}, :north), do: {x, y - 1}

  defp turn(:east), do: :south
  defp turn(:west), do: :north
  defp turn(:south), do: :west
  defp turn(:north), do: :east
end
