defmodule CollatzConjecture do
  @doc """
  calc/1 takes an integer and returns the number of steps required to get the
  number to 1 when following the rules:
    - if number is odd, multiply with 3 and add 1
    - if number is even, divide by 2
  """
  @spec calc(input :: pos_integer()) :: non_neg_integer()
  def calc(input) when is_integer(input) and input > 0 do
    Stream.iterate(input, fn n ->
      if rem(n, 2) == 1 do
        n * 3 + 1
      else
        div(n, 2)
      end
    end)
    |> Enum.take_while(&(&1 != 1))
    |> length()
  end
end
