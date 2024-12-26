defmodule Math do
  @moduledoc """
  Some mathematical stuff I don't have elsewhere.
  """

  @doc """
  Produces a list of permutations of all the elements in the provided `list` (order matters).
  """
  @spec permutations(list()) :: list(list())
  def permutations([]), do: [[]]

  def permutations(list) when is_list(list) do
    for x <- list, y <- permutations(list -- [x]), do: [x | y]
  end

  @doc """
  Produces a selection of `length` items from a `list` that has distinct members, such that the
  order of selection does not matter.
  """
  @spec combinations(length :: non_neg_integer(), list()) :: list(list(())
  def combinations(0, []), do: [[]]
  def combinations(_, []), do: []

  def combinations(length, [h | t]) do
    for(xs <- combinations(length - 1, t), do: [h | xs]) ++ combinations(length, t)
  end
end
