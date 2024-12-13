defmodule AllYourBase do
  @doc """
  Given a number in input base, represented as a sequence of digits, converts it to output base,
  or returns an error tuple if either of the bases are less than 2
  """

  @spec convert(list, integer, integer) :: {:ok, list} | {:error, String.t()}
  def convert(_, input_base, _) when input_base < 2, do: {:error, "input base must be >= 2"}
  def convert(_, _, output_base) when output_base < 2, do: {:error, "output base must be >= 2"}

  def convert(digits, input_base, output_base) do
    if Enum.all?(digits, &(&1 >= 0 and &1 < input_base)) do
      output_digits =
        digits
        |> Enum.reduce(0, fn n, acc -> acc * input_base + n end)
        |> to_base(output_base)

      {:ok, output_digits}
    else
      {:error, "all digits must be >= 0 and < input base"}
    end
  end

  defp to_base(n, base, acc \\ [])
  defp to_base(0, _, []), do: [0]
  defp to_base(0, _, acc), do: acc

  defp to_base(n, base, acc) do
    to_base(div(n, base), base, [rem(n, base) | acc])
  end
end
