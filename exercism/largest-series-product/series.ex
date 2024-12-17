defmodule Series do
  @doc """
  Finds the largest product of a given number of consecutive numbers in a given string of numbers.
  """
  @spec largest_product(String.t(), non_neg_integer) :: non_neg_integer
  def largest_product(_, size) when size < 1, do: raise(ArgumentError)

  def largest_product(number_string, size) do
    if String.length(number_string) < size, do: raise(ArgumentError)

    number_string
    |> String.to_integer()
    |> Integer.digits()
    |> Enum.chunk_every(size, 1, :discard)
    |> Enum.reduce(0, fn seq, acc ->
      product = Enum.product(seq)
      if(product > acc, do: product, else: acc)
    end)
  end
end
