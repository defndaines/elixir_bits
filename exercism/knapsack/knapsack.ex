defmodule Knapsack do
  @doc """
  Return the maximum value that a knapsack can carry.
  """
  @spec maximum_value(items :: [%{value: integer, weight: integer}], maximum_weight :: integer) ::
          integer
  def maximum_value(items, maximum_weight) do
    items
    |> permutations()
    |> Enum.map(fn sack ->
      Enum.reduce_while(sack, {[], 0, 0}, fn e, {acc, weight, value} ->
        if weight + e.weight > maximum_weight do
          {:halt, {acc, weight, value}}
        else
          {:cont, {[e | acc], weight + e.weight, value + e.value}}
        end
      end)
      |> Kernel.elem(2)
    end)
    |> Enum.max(&>/2, 0)
  end

  def permutations([]), do: [[]]

  def permutations(list) when is_list(list) do
    for x <- list, y <- permutations(list -- [x]), do: [x | y]
  end

  defp weight(list), do: list |> Enum.map(& &1.weight) |> Enum.sum()
end
