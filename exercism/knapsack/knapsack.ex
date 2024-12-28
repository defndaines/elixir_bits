defmodule Knapsack do
  @doc """
  Return the maximum value that a knapsack can carry.
  """
  @spec maximum_value(items :: [%{value: integer, weight: integer}], maximum_weight :: integer) ::
          integer
  def maximum_value([], _maximum_weight), do: 0

  def maximum_value([item | rest], maximum_weight) when item.weight > maximum_weight do
    maximum_value(rest, maximum_weight)
  end

  def maximum_value([item | rest], maximum_weight) do
    max(
      maximum_value(rest, maximum_weight),
      maximum_value(rest, maximum_weight - item.weight) + item.value
    )
  end
end
