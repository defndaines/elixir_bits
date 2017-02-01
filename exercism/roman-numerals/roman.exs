defmodule Roman do

  @roman_numerals [{1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"},
                   {100, "C"}, {90, "XC"}, {50, "L"}, {40, "XL"},
                   {10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"},
                   {1, "I"}]

  @doc """
  Convert the number to a roman number.
  """
  @spec numerals(pos_integer) :: String.t
  def numerals(number) do
    numerals(number, @roman_numerals)
  end

  defp numerals(0, _romans), do: ""
  defp numerals(n, [{arab, roman} | tail]) when n >= arab do
    roman <> numerals(n - arab, [{arab, roman} | tail])
  end
  defp numerals(n, [_head | tail]), do: numerals(n, tail)
end