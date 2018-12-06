defmodule Day2 do
  @moduledoc """
  Solutions to Day 2 of 2018 Advent of Code. Inventory Management System
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

  defp distance([], [], acc), do: {:ok, acc}
  defp distance(_, _, acc) when acc > 1, do: {:too_large, acc}
  defp distance([c | rest_1], [c | rest_2], acc) do
    distance(rest_1, rest_2, acc)
  end
  defp distance([_ | rest_1], [_ | rest_2], acc) do
    distance(rest_1, rest_2, acc + 1)
  end

  def close_ids([id | ids]) do
    id_list = String.to_charlist(id)
    candidates = Enum.filter(ids, fn x ->
      {k, _} = distance(id_list, String.to_charlist(x), 0)
      k == :ok
    end)

    case candidates do
      [] -> close_ids(ids)
      [match | _] -> commonalities({id, match})
    end
  end

  defp matching_char_reducer(e, acc) do
    case e do
      {a, a} -> [a | acc]
      _ -> acc
    end
  end

  defp commonalities({id_1, id_2}) do
    Enum.zip(String.to_charlist(id_1), String.to_charlist(id_2))
    |> Enum.reduce([], &matching_char_reducer/2)
    |> Enum.reverse
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
    result = close_ids(input_to_list())
    IO.puts(result)
  end
end

