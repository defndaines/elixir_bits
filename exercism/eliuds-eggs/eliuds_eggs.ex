defmodule EliudsEggs do
  @doc """
  Given the number, count the number of eggs.
  """
  import Bitwise

  @spec egg_count(number :: integer()) :: non_neg_integer()
  def egg_count(0), do: 0

  def egg_count(number) do
    band(number, 1) + egg_count(bsr(number, 1))
  end
end
