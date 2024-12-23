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

  def scan_for_reaction([a, b | rest], acc, last) when a == b + 32 do
    scan_for_reaction(rest, acc, last)
  end

  def scan_for_reaction([a, b | rest], acc, last) when b == a + 32 do
    scan_for_reaction(rest, acc, last)
  end

  def scan_for_reaction([ch | rest], acc, last) do
    scan_for_reaction(rest, [ch | acc], last)
  end

  @doc """
  Scan an input string for reactions, but selectively remove one polymer from
  the entire chain and return the value which produces the smallest sequence.
  """
  def scan_with_removal(input) do
    Enum.map(?A..?Z, fn ch -> Regex.compile!(to_string([~c"[", ch, ch + 32, ~c"]"])) end)
    |> Enum.map(fn regex -> String.replace(input, regex, "") end)
    |> Enum.map(&Task.async(fn -> scan_for_reaction(&1) end))
    |> Enum.map(&Task.await/1)
    |> Enum.sort(&(length(&1) <= length(&2)))
    |> Enum.at(0)
  end
end

ExUnit.start()

defmodule Day5Test do
  use ExUnit.Case

  import Day5

  test "scan for reaction" do
    input = "kKpPcCZQqzyYvVxXVfYLl"
    ~c"VfY" = scan_for_reaction(input)
  end

  test "part one" do
    {:ok, input} = File.read("input")
    result = scan_for_reaction(input)
    IO.puts(length(result))
  end

  test "scan for best with removed polymer" do
    input = "dabAcCaCBAcCcaDA"
    ~c"daDA" = scan_with_removal(input)
  end

  test "part two" do
    {:ok, input} = File.read("input")
    result = scan_with_removal(input)
    IO.puts(length(result))
  end
end
