defmodule Day3 do
  @moduledoc """
  Solutions to Day 3 of 2018 Advent of Code. No Matter How You Slice It
  https://adventofcode.com/2018/day/3
  """

  @line_regex ~r{#\d+ @ (\d+),(\d+): (\d+)x(\d+)$}

  @doc """
  Read a list of claims from a file.

  Example data:
  #1 @ 861,330: 20x10
  #2 @ 491,428: 28x23
  #3 @ 64,746: 20x27
  """
  def input_to_list() do
    {:ok, input} = File.read("input")
    String.split(input, "\n", trim: true)
  end

  def parse_line(line) do
    Regex.run(@line_regex, line, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
  end

  def claim_reducer(e, acc) do
    [left, top, width, height] = parse_line(e)
    coords = for x <- left..(left + width - 1), y <- top..(top + height - 1), do: {x, y}
    Enum.reduce(coords, acc, fn coord, acc -> Map.put(acc, coord, Map.get(acc, coord, 0) + 1) end)
  end

  @doc """
  Analyze all the claims in the input file and identify how many squares have
  overlapping claims, that is, multiple claims cross the same squares of
  fabric.
  """
  def overlapping_claims() do
    Enum.reduce(input_to_list(), %{}, &claim_reducer/2)
    |> Map.values()
    |> Enum.filter(fn x -> x > 1 end)
    |> Kernel.length()
  end

  defp assess_claim(claim, all_claims) do
    [left, top, width, height] = parse_line(claim)
    coords = for x <- left..(left + width - 1), y <- top..(top + height - 1), do: {x, y}

    Enum.all?(coords, fn coord -> Map.get(all_claims, coord) == 1 end)
  end

  @doc """
  Identify the claim which does not overlap with any other claim.
  """
  def isolated_claim() do
    input = input_to_list()
    all_claims = Enum.reduce(input, %{}, &claim_reducer/2)

    Enum.filter(input, fn claim -> assess_claim(claim, all_claims) end)
  end
end

ExUnit.start()

defmodule Day3Test do
  use ExUnit.Case

  import Day3

  test "parse line" do
    line = "#2 @ 491,428: 28x23"
    [491, 428, 28, 23] = parse_line(line)
  end

  test "claim reducer" do
    %{{2, 3} => 1, {2, 4} => 1, {3, 3} => 1, {3, 4} => 1} =
      claim_reducer("#2 @ 2,3: 2x2", %{})

    claims = ["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"]

    %{
      {1, 3} => 1,
      {1, 4} => 1,
      {1, 5} => 1,
      {1, 6} => 1,
      {2, 3} => 1,
      {2, 4} => 1,
      {2, 5} => 1,
      {2, 6} => 1,
      {3, 1} => 1,
      {3, 2} => 1,
      {3, 3} => 2,
      {3, 4} => 2,
      {3, 5} => 1,
      {3, 6} => 1,
      {4, 1} => 1,
      {4, 2} => 1,
      {4, 3} => 2,
      {4, 4} => 2,
      {4, 5} => 1,
      {4, 6} => 1,
      {5, 1} => 1,
      {5, 2} => 1,
      {5, 3} => 1,
      {5, 4} => 1,
      {5, 5} => 1,
      {5, 6} => 1,
      {6, 1} => 1,
      {6, 2} => 1,
      {6, 3} => 1,
      {6, 4} => 1,
      {6, 5} => 1,
      {6, 6} => 1
    } =
      Enum.reduce(claims, %{}, &claim_reducer/2)
  end

  test "part one" do
    IO.puts(overlapping_claims())
  end

  test "part two" do
    IO.puts(isolated_claim())
  end
end
