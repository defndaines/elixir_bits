defmodule ResistorColorTrio do
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

  @scale [:ohms, :kiloohms, :megaohms, :gigaohms]

  @doc """
  Calculate the resistance value in ohms from resistor colors
  """
  @spec label(colors :: [atom]) :: {number, :ohms | :kiloohms | :megaohms | :gigaohms}
  def label(colors), do: colors |> Enum.take(3) |> do_label()

  defp do_label(colors, acc \\ 0)
  defp do_label([:black], 0), do: {0, :ohms}

  defp do_label([color], acc) do
    ohms = acc * 10 ** @resistors[color]

    Enum.reduce_while(@scale, ohms, fn unit, acc ->
      if div(acc, 1000) * 1000 == acc do
        {:cont, div(acc, 1000)}
      else
        {:halt, {acc, unit}}
      end
    end)
  end

  defp do_label([color | rest], acc), do: do_label(rest, acc * 10 + @resistors[color])
end
