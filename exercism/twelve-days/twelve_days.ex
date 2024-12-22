defmodule TwelveDays do
  @ordinals ~w(zeroth first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelfth)

  @gifts %{
    1 => "a Partridge in a Pear Tree",
    2 => "two Turtle Doves",
    3 => "three French Hens",
    4 => "four Calling Birds",
    5 => "five Gold Rings",
    6 => "six Geese-a-Laying",
    7 => "seven Swans-a-Swimming",
    8 => "eight Maids-a-Milking",
    9 => "nine Ladies Dancing",
    10 => "ten Lords-a-Leaping",
    11 => "eleven Pipers Piping",
    12 => "twelve Drummers Drumming"
  }

  @doc """
  Given a `number`, return the song's verse for that specific day, including
  all gifts for previous days in the same line.
  """
  @spec verse(number :: integer) :: String.t()
  def verse(number) do
    "On the #{Enum.at(@ordinals, number)} day of Christmas my true love gave to me: #{gift(number)}."
  end

  defp gift(n, acc \\ [])
  defp gift(1, []), do: @gifts[1]
  defp gift(1, acc), do: Enum.join(acc ++ ["and " <> @gifts[1]], ", ")
  defp gift(n, acc), do: gift(n - 1, acc ++ [@gifts[n]])

  @doc """
  Given a `starting_verse` and an `ending_verse`, return the verses for each
  included day, one per line.
  """
  @spec verses(starting_verse :: integer, ending_verse :: integer) :: String.t()
  def verses(starting_verse, ending_verse) do
    starting_verse..ending_verse |> Enum.map(&verse/1) |> Enum.join("\n")
  end

  @doc """
  Sing all 12 verses, in order, one verse per line.
  """
  @spec sing() :: String.t()
  def sing, do: verses(1, 12)
end
