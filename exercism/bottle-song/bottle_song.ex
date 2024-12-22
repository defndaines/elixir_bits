defmodule BottleSong do
  @moduledoc """
  Handles lyrics of the popular children song: Ten Green Bottles
  """

  @spec recite(pos_integer, pos_integer) :: String.t()
  def recite(start_bottle, take_down) do
    verses =
      for n <- start_bottle..(start_bottle - take_down + 1)//-1 do
        at_start = n |> bottles() |> String.capitalize()

        """
        #{at_start} hanging on the wall,
        #{at_start} hanging on the wall,
        And if one green bottle should accidentally fall,
        There'll be #{bottles(n - 1)} hanging on the wall.\
        """
      end

    Enum.join(verses, "\n\n")
  end

  @words ~w(no one two three four five six seven eight nine ten)

  defp bottles(1), do: "one green bottle"
  defp bottles(n), do: "#{Enum.at(@words, n)} green bottles"
end
