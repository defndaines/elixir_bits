defmodule Luhn do
  @doc """
  Checks if the given number is valid via the luhn formula
  """
  @spec valid?(String.t()) :: boolean
  def valid?(number) do
    case valid_digits(number) do
      :invalid -> false
      digits -> sum_div_by_10?(double_every_other(digits))
    end
  end

  defp valid_digits(number, acc \\ [])
  defp valid_digits("", acc) when length(acc) < 2, do: :invalid
  defp valid_digits("", acc), do: acc
  defp valid_digits(" " <> rest, acc), do: valid_digits(rest, acc)
  defp valid_digits(<<n, rest::binary>>, acc) when n in ?0..?9 do
    valid_digits(rest, [n - ?0 | acc])
  end
  defp valid_digits(_, _), do: :invalid

  defp double_every_other(numbers, acc \\ [])
  defp double_every_other([], acc), do: acc
  defp double_every_other([n], acc), do: [n | acc]
  defp double_every_other([n, m | rest], acc) when m > 4 do
    double_every_other(rest, [m * 2 - 9, n | acc])
  end
  defp double_every_other([n, m | rest], acc) do
    double_every_other(rest, [m * 2, n | acc])
  end

  defp sum_div_by_10?(numbers) do
    rem(Enum.sum(numbers), 10) == 0
  end
end
