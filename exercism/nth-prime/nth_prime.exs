defmodule Prime do
  @doc """
  Generates the nth prime.
  """
  @spec nth(non_neg_integer) :: non_neg_integer
  def nth(1), do: 2
  def nth(2), do: 3

  def nth(count) when count > 2 do
    Stream.iterate(3, &(&1 + 2))
    5
  end
end
