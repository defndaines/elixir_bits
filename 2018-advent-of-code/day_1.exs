defmodule Day1 do
  @moduledoc """
  Solutions to Day 1 of 2018 Advent of Code. Chronal Calibration
  https://adventofcode.com/2018/day/1
  """

  @doc """
  Read a list of modulations (positive or negative integers) from a file.

  Example data:
  +10
  -9
  +12
  +5

  Returns a list of integer values for each line in the input file.
  """
  def input_to_list() do
    {:ok, input} = File.read("input")

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Iterate through a list of frequency calibrations, accumulating each one.

  Returns the final result of applying all calibrations.
  """
  def calibrate(inputs) do
    Enum.reduce(inputs, 0, &+/2)
  end

  @doc """
  Cycle through a list of frequency calibrations, keeping track of each
  frequency seen so far. The calibrations continue back at the start of the
  list when the end of the list has been reached but a repeat has not yet been
  found.

  Returns the first frequency that is arrived at twice.
  """
  def first_repeat(base) do
    first_repeat(base, 0, %{0 => 1}, base)
  end

  def first_repeat([], acc, seen, base) do
    first_repeat(base, acc, seen, base)
  end

  def first_repeat([head | tail], acc, seen, base) do
    freq = head + acc

    case Map.get(seen, freq) do
      nil -> first_repeat(tail, freq, Map.put(seen, freq, 1), base)
      _ -> freq
    end
  end
end

ExUnit.start()

defmodule Day1Test do
  use ExUnit.Case

  import Day1

  test "part one" do
    result = calibrate(input_to_list())
    IO.puts(result)
  end

  test "part two" do
    repeater = first_repeat(input_to_list())
    IO.puts(repeater)
  end
end
