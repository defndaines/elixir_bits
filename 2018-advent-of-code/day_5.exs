defmodule Day5 do
  @moduledoc """
  Solutions to Day 5 of 2018 Advent of Code. Alchemical Reduction
  https://adventofcode.com/2018/day/5
  """

  @doc """
  Traverse a string of polymers, removing reactions, which occur when a
  capital- and lower-case of the same letter occur next to each other.

  Returns a charlist which has all reactions removed.
  """
  def scan_for_reaction(input) do
    cl = to_charlist(String.trim(input))
    scan_for_reaction(cl, [], cl)
  end

  def scan_for_reaction([], acc, last) do
    result = Enum.reverse(acc)
    case last == result do
      true -> last
      false -> scan_for_reaction(result, [], result)
    end
  end
  def scan_for_reaction([a, b | rest], acc, last) when a == (b + 32) do
    scan_for_reaction(rest, acc, last)
  end
  def scan_for_reaction([a, b | rest], acc, last) when b == (a + 32) do
    scan_for_reaction(rest, acc, last)
  end
  def scan_for_reaction([ch | rest], acc, last) do
    scan_for_reaction(rest, [ch | acc], last)
  end
end

ExUnit.start()

defmodule Day5Test do
  use ExUnit.Case

  import Day5

  test "scan for reaction" do
    input = "kKpPcCZQqzyYvVxXVfYLl"
    'VfY' = scan_for_reaction(input)
  end

  test "part one" do
    {:ok, input} = File.read("input")
    result = scan_for_reaction(input)
    IO.puts(length(result))
  end

  test "part two" do
    # IO.puts()
  end
end
