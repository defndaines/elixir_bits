defmodule Day4 do
  @moduledoc """
  Solutions to Day 4 of 2018 Advent of Code. Repose Record
  https://adventofcode.com/2018/day/4
  """

  @line_regex ~r/:(\d\d)\] (.*)/

  @doc """
  Read a list of repose records from a file.

  Example data:
  [1518-03-10 23:57] Guard #73 begins shift
  [1518-03-11 00:06] falls asleep
  [1518-03-11 00:22] wakes up
  """
  def input_to_list() do
    {:ok, input} = File.read("input")

    String.split(input, "\n", trim: true)
    |> Enum.sort()
  end

  defp parse_guard_id(message) do
    Regex.run(~r{ #(\d+) }, message)
    |> Enum.at(1)
    |> String.to_integer()
  end

  def parse_line(line) do
    [minutes, message] = Regex.run(@line_regex, line, capture: :all_but_first)

    case String.slice(message, 0, 5) do
      "Guard" -> {:guard, parse_guard_id(message)}
      "falls" -> {:sleep, String.to_integer(minutes)}
      "wakes" -> {:wakes, String.to_integer(minutes)}
    end
  end

  def update_guard_record(acc, guard_id, start, finish) do
    guard_record = Map.get(acc, guard_id, %{})

    updated =
      Enum.reduce(
        start..(finish - 1),
        guard_record,
        fn minute, acc -> Map.put(acc, minute, Map.get(acc, minute, 0) + 1) end
      )

    Map.put(acc, guard_id, updated)
  end

  def assess_record(e, {guard_id, start, acc}) do
    case parse_line(e) do
      {:guard, id} -> {id, start, acc}
      {:sleep, minute} -> {guard_id, minute, acc}
      {:wakes, minute} -> {guard_id, start, update_guard_record(acc, guard_id, start, minute)}
    end
  end

  defp time_asleep_comparator({_, a}, {_, b}) do
    Enum.reduce(Map.values(a), &+/2) >= Enum.reduce(Map.values(b), &+/2)
  end

  @doc """
  Find the guard that has the most minutes asleep. What minute does that guard
  spend asleep the most?

  Return the ID of the guard multiplied by the minute.
  """
  def strategy_one() do
    {_, _, all_records} = Enum.reduce(input_to_list(), {nil, nil, %{}}, &assess_record/2)
    [{sleepiest_guard, minutes} | _] = Enum.sort(all_records, &time_asleep_comparator/2)
    [{minute, _} | _] = Enum.sort(minutes, fn {_, v1}, {_, v2} -> v1 >= v2 end)
    sleepiest_guard * minute
  end

  defp sleep_minute_comparator({_, a}, {_, b}) do
    Enum.at(Enum.sort(Map.values(a), &(&1 >= &2)), 0) >=
      Enum.at(Enum.sort(Map.values(b), &(&1 >= &2)), 0)
  end

  @doc """
  Of all guards, which guard is most frequently asleep on the same minute?

  Return the ID of the guard multiplied by the minute.
  """
  def strategy_two() do
    {_, _, all_records} = Enum.reduce(input_to_list(), {nil, nil, %{}}, &assess_record/2)
    [{sleepiest_guard, minutes} | _] = Enum.sort(all_records, &sleep_minute_comparator/2)
    [{minute, _} | _] = Enum.sort(minutes, fn {_, v1}, {_, v2} -> v1 >= v2 end)
    sleepiest_guard * minute
  end
end

ExUnit.start()

defmodule Day4Test do
  use ExUnit.Case

  import Day4

  test "parse line" do
    guard_line = "[1518-03-10 23:57] Guard #73 begins shift"
    {:guard, 73} = parse_line(guard_line)

    sleep_line = "[1518-03-11 00:06] falls asleep"
    {:sleep, 6} = parse_line(sleep_line)

    wake_line = "[1518-03-11 00:22] wakes up"
    {:wakes, 22} = parse_line(wake_line)
  end

  test "input is sorted" do
    input = input_to_list()

    [
      "[1518-03-10 23:57] Guard #73 begins shift",
      "[1518-03-11 00:06] falls asleep",
      "[1518-03-11 00:22] wakes up"
    ] = Enum.take(input, 3)

    [
      "[1518-11-22 23:59] Guard #3109 begins shift",
      "[1518-11-23 00:21] falls asleep",
      "[1518-11-23 00:29] wakes up"
    ] = Enum.drop(input, 1061)
  end

  test "updating a guard record" do
    %{52 => %{5 => 1, 6 => 1}} = update_guard_record(%{}, 52, 5, 7)

    %{52 => %{5 => 1, 6 => 2, 7 => 1, 8 => 1}} =
      update_guard_record(%{52 => %{5 => 1, 6 => 1}}, 52, 6, 9)
  end

  test "assess record reducer" do
    guard_line = "[1518-03-10 23:57] Guard #73 begins shift"
    {73, nil, %{}} = assess_record(guard_line, {nil, nil, %{}})

    sleep_line = "[1518-03-11 00:06] falls asleep"
    {73, 6, %{}} = assess_record(sleep_line, {73, nil, %{}})

    wake_line = "[1518-03-11 00:22] wakes up"

    sleep_minutes = %{
      6 => 1,
      7 => 1,
      8 => 1,
      9 => 1,
      10 => 1,
      11 => 1,
      12 => 1,
      13 => 1,
      14 => 1,
      15 => 1,
      16 => 1,
      17 => 1,
      18 => 1,
      19 => 1,
      20 => 1,
      21 => 1
    }

    {73, 6, results} = assess_record(wake_line, {73, 6, %{}})
    assert results == %{73 => sleep_minutes}
    assert Map.keys(Map.get(results, 73)) == Map.keys(sleep_minutes)
  end

  test "part one" do
    result = strategy_one()
    IO.puts(result)
  end

  test "part two" do
    result = strategy_two()
    IO.puts(result)
  end
end
