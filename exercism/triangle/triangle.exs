defmodule Triangle do
  @type kind :: :equilateral | :isosceles | :scalene

  @doc """
  Return the kind of triangle of a triangle with 'a', 'b' and 'c' as lengths.
  """
  @spec kind(number, number, number) :: {:ok, kind} | {:error, String.t()}
  def kind(a, b, c) do
    kind(Enum.sort([a, b, c]))
  end

  defp kind([a | _]) when a <= 0 do
    {:error, "all side lengths must be positive"}
  end

  defp kind([a, a, a]), do: {:ok, :equilateral}

  defp kind([a, b, c]) when a + b <= c do
    {:error, "side lengths violate triangle inequality"}
  end

  defp kind([_, a, a]), do: {:ok, :isosceles}
  defp kind(_), do: {:ok, :scalene}
end
