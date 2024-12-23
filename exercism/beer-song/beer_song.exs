defmodule BeerSong do
  @doc """
  Get a single verse of the beer song
  """
  @spec verse(integer) :: String.t()
  def verse(number) do
    # Your implementation here...
    """
    #{String.capitalize(bottles(number))} of beer on the wall, #{bottles(number)} of beer.
    #{action(number)}, #{bottles(number - 1)} of beer on the wall.
    """
  end

  @doc """
  Get the entire beer song for a given range of numbers of bottles.
  """
  @spec lyrics(Range.t()) :: String.t()
  def lyrics(range \\ 99..0) do
    range |> Enum.map(&verse/1) |> Enum.join("\n")
  end

  defp bottles(-1), do: "99 bottles"
  defp bottles(0), do: "no more bottles"
  defp bottles(1), do: "1 bottle"
  defp bottles(n), do: "#{n} bottles"

  defp action(0), do: "Go to the store and buy some more"
  defp action(1), do: "Take it down and pass it around"
  defp action(n), do: "Take one down and pass it around"
end
