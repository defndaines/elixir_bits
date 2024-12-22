defmodule PrimeFactors do
  @doc """
  Compute the prime factors for 'number'.

  The prime factors are prime numbers that when multiplied give the desired
  number.

  The prime factors of 'number' will be ordered lowest to highest.
  """
  @spec factors_for(pos_integer) :: [pos_integer]
  def factors_for(number), do: do_factors(number)

  defp do_factors(n, f \\ 2)
  defp do_factors(1, _), do: []
  defp do_factors(n, f) when rem(n, f) == 0, do: [f | do_factors(div(n, f), f)]
  defp do_factors(n, 2), do: do_factors(n, 3)
  defp do_factors(n, f), do: do_factors(n, f + 2)
end
