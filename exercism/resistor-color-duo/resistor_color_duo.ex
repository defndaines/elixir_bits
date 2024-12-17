defmodule ResistorColorDuo do
  @resistors %{
    black: 0,
    brown: 1,
    red: 2,
    orange: 3,
    yellow: 4,
    green: 5,
    blue: 6,
    violet: 7,
    grey: 8,
    white: 9
  }

  @doc """
  Calculate a resistance value from two colors
  """
  @spec value(colors :: [atom]) :: integer
  def value(colors), do: colors |> Enum.take(2) |> do_value()

  defp do_value(colors, acc \\ 0)
  defp do_value([], acc), do: acc
  defp do_value([color | rest], acc), do: do_value(rest, acc * 10 + @resistors[color])
end
