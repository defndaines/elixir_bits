defmodule PalindromeProducts do
  @doc """
  Generates all palindrome products from an optionally given min factor (or 1) to a given max factor.
  """
  @spec generate(non_neg_integer, non_neg_integer) :: map
  def generate(max_factor, min_factor \\ 1)
  def generate(max_factor, min_factor) when min_factor > max_factor, do: raise(ArgumentError)

  def generate(max_factor, min_factor) do
    range = min_factor..max_factor

    for(x <- range, y <- range, x <= y, prod = x * y, palindrome?(prod), do: {prod, [x, y]})
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.update(acc, k, [v], &[v | &1]) end)
  end

  defp palindrome?(n) do
    digits = Integer.digits(n)
    digits == Enum.reverse(digits)
  end
end
