defmodule Rectangles do
  @doc """
  Count the number of ASCII rectangles.
  """
  @spec count(input :: String.t()) :: integer
  def count(input) do
    grid =
      for {row, y} <- input |> String.split("\n") |> Enum.with_index(),
          {v, x} <- row |> String.graphemes() |> Enum.with_index(),
          into: %{} do
        {{x, y}, v}
      end

    grid
    |> Map.keys()
    |> Enum.sort()
    |> Enum.filter(&(Map.get(grid, &1) == "+"))
    |> rectangles(grid)
  end

  defp rectangles([], _), do: 0

  defp rectangles([{x, y} | rest], grid) do
    rest
    |> Enum.filter(&match?({^x, _}, &1))
    |> Enum.reduce(0, fn {^x, b}, total ->
      rest
      |> Enum.filter(&match?({_, ^y}, &1))
      |> Enum.reduce(0, fn {a, ^y}, acc ->
        if Enum.member?(rest, {a, b}) and valid?([{x, y}, {x, b}, {a, y}, {a, b}], grid) do
          acc + 1
        else
          acc
        end
      end)
      |> Kernel.+(total)
    end)
    |> Kernel.+(rectangles(rest, grid))
  end

  defp valid?([{x, y}, {x, b}, {a, y}, {a, b}], grid) do
    Enum.all?(x..a, fn m -> Enum.member?(["+", "-"], Map.get(grid, {m, y})) end) and
      Enum.all?(x..a, fn m -> Enum.member?(["+", "-"], Map.get(grid, {m, b})) end) and
      Enum.all?(y..b, fn n -> Enum.member?(["+", "|"], Map.get(grid, {x, n})) end) and
      Enum.all?(y..b, fn n -> Enum.member?(["+", "|"], Map.get(grid, {a, n})) end)
  end

  defp valid?(_, _), do: false
end
