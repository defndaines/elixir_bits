defmodule Sieve do
  @doc """
  Generates a list of primes up to a given limit.
  """
  @spec primes_to(non_neg_integer) :: [non_neg_integer]
  def primes_to(limit, acc \\ []) do
    sieve(Enum.to_list(2..limit), [])
  end

  defp sieve([], acc), do: Enum.reverse(acc)
  defp sieve([prime | rest], acc) do
    sieve(Enum.reject(rest, &(rem(&1, prime) == 0)), [prime | acc])
  end
end
