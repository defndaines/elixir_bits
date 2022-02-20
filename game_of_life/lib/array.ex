defmodule Array do
  @moduledoc """
  Two-dimensional array functions for direct index access of a grid.
  Thin layer over Erlang's :array library.
  """

  def get(array, {x, y}, default \\ 0) do
    if in_bounds?(array, {x, y}) do
      :array.get(y, :array.get(x, array))
    else
      default
    end
  end

  def from_list(grid) do
    Enum.reduce(
      Enum.with_index(grid),
      :array.new([{:default, 0}]),
      fn {row, x}, acc -> :array.set(x, :array.from_list(row, 0), acc) end
    )
  end

  def to_list(array) do
    :array.foldr(fn _x, row, acc -> [:array.to_list(row) | acc] end, [], array)
  end

  def in_bounds?(array, {x, y}) do
    x >= 0 and y >= 0 and x < :array.size(array) and y < :array.size(:array.get(0, array))
  end

  def neighbors(array, {x, y}, match_on \\ [1]) do
    [
      {x - 1, y - 1}, {x - 1, y}, {x - 1, y + 1},
      {x    , y - 1},             {x    , y + 1},
      {x + 1, y - 1}, {x + 1, y}, {x + 1, y + 1}
    ]
    |> Enum.map(fn pos -> get(array, pos) end)
    |> Enum.filter(&(&1 in match_on))
    |> Enum.count()
  end
end
