defmodule Day2 do
  @moduledoc """
  Solutions to Day 2 of 2018 Advent of Code.
  https://adventofcode.com/2018/day/2
  """

  @doc """
  Read a list of box IDs from a file.

  Example data:
  bqlpzruexkszyahnamgjdctvfs
  bqlporuexkwyyahnbmgjdctvfb
  bqlhoruexkwzyahefmgjdctvfs

  Returns a list of string values for each line in the input file.
  """
  def input_to_list() do
    {:ok, input} = File.read("input")
    String.split(input, "\n", trim: true)
  end

  defp char_freq(id) do
    Enum.reduce(String.split(id, "", trim: true),
      %{},
      fn e, acc -> Map.put(acc, e, Map.get(acc, e, 0) + 1) end)
  end

  defp checksum_reducer(e, {twos, threes}) do
    frequencies = Map.values(e)
    {Enum.member?(frequencies, 2) && twos + 1 || twos,
      Enum.member?(frequencies, 3) && threes + 1 || threes}
  end

  @doc """
  Calculate the checksum for a list of IDs.
  """
  def checksum(ids) do
    {twos, threes} = Enum.map(ids, &char_freq/1)
                     |> Enum.reduce({0, 0}, &checksum_reducer/2)
    twos * threes
  end

end

ExUnit.start()

defmodule Day2Test do
  use ExUnit.Case

  import Day2

  test "part one" do
    result = checksum(input_to_list())
    IO.puts(result)
  end

  test "part two" do
  end
end

