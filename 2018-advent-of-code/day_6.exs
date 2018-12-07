defmodule Day6 do
  @moduledoc """
  Solutions to Day 6 of 2018 Advent of Code. Chronal Coordinates
  https://adventofcode.com/2018/day/6
  """

  @line_regex ~r{^(\d+), (\d+)$}

  @doc """
  Read a list of coordinates from a file.

  Example data:
  227, 133
  140, 168
  99, 112
  """
  def input_to_list() do
    {:ok, input} = File.read("input")
    String.split(input, "\n", trim: true)
    |> Enum.map(fn line -> Regex.run(@line_regex, line, [capture: :all_but_first]) end)
    |> Enum.map(fn [x, y] -> {String.to_integer(x), String.to_integer(y)} end)
  end

  def bounds(coords) do
    xs = Enum.sort(coords, fn {x1, _}, {x2, _} -> x1 <= x2 end)
    ys = Enum.sort(coords, fn {_, y1}, {_, y2} -> y1 <= y2 end)
    {x, _} = Enum.at(xs, 0)
    {x_, _} = Enum.at(xs, -1)
    {_, y} = Enum.at(ys, 0)
    {_, y_} = Enum.at(ys, -1)
    {{x, y}, {x_, y_}}
  end

  def manhattan_distance({x, y}, {a, b}) do
    abs(x - a) + abs(y - b)
  end

  def closest_points(point, list) do
    dists = Enum.map(list, fn coord -> {coord, manhattan_distance(point, coord)} end)
            |> Enum.sort(fn {_, dist_1}, {_, dist_2} -> dist_1 <= dist_2 end)
    {_, closest} = Enum.at(dists, 0)
    Enum.take_while(dists, fn {_, dist} -> closest == dist end)
    |> Enum.map(fn {coord, _} -> coord end)
  end

  def map_closest_coord(input) do
    {{min_x, min_y}, {max_x, max_y}} = bounds(input)
    all_keys = for x <- min_x..max_x, y <- min_y..max_y, do: {x, y}
    Enum.reduce(all_keys, %{},
      fn e, acc -> case closest_points(e, input) do
        [point] -> Map.put(acc, e, point)
        _ -> acc
          end
      end)
  end

  defp frequencies(list) do
    Enum.reduce(list, %{}, fn e, acc -> case e do
      nil -> acc
      point -> Map.put(acc, point, Map.get(acc, point, 0) + 1)
    end
    end)
  end

  def border_points(coords, closest) do
    {{min_x, min_y}, {max_x, max_y}} = bounds(coords)
    left = for y <- min_y..max_y, do: Map.get(closest, {min_x, y})
    right = for y <- min_y..max_y, do: Map.get(closest, {max_x, y})
    top = for x <- min_x..max_x, do: Map.get(closest, {x, max_y})
    bottom = for x <- min_x..max_x, do: Map.get(closest, {x, min_y})
    Enum.uniq(left ++ right ++ top ++ bottom) |> Enum.filter(&(&1))
  end

  @doc """
  Find the coordinate with the largest territory closest to its position, but
  excluding infinite territories (those along the edges which technically
  extend on forever.
  """
  def largest_non_infinite_area() do
    coords = input_to_list()
    closest = map_closest_coord(coords)
    boundaries = border_points(coords, closest)

    {_, size} = Map.values(closest)
                |> Enum.filter(fn point -> Enum.find(boundaries, &(&1 == point)) == nil end)
                |> frequencies
                |> Enum.sort(fn {_, count_1}, {_, count_2} -> count_1 >= count_2 end)
                |> Enum.at(0)

    size
  end
end

ExUnit.start()

defmodule Day6Test do
  use ExUnit.Case

  import Day6

  test "input to list" do
    coords = input_to_list()
    [ {227, 133},
      {140, 168},
      {99, 112}] = Enum.take(coords, 3)
    assert 50 == length(coords)
  end

  test "bounds" do
    coords = input_to_list()
    {{40, 50}, {338, 353}} = bounds(coords)
  end

  test "closest points" do
    coords = [{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}]

    # Identity
    [{1, 1}] = closest_points({1, 1}, coords) 

    # By distance
    [{5, 5}] = closest_points({5, 8}, coords)

    # Allow for ties
    [{1, 6}, {3, 4}] = closest_points({3, 6}, coords)
  end

  test "map closest coordinates" do
    coords = [{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}]
    closest = map_closest_coord(coords)

    # Identity: Coordinates are their closest point
    {1, 1} = Map.get(closest, {1, 1})

    {5, 5} = Map.get(closest, {5, 8})

    :undefined = Map.get(closest, {3, 6}, :undefined)
  end

  test "part one" do
    result = largest_non_infinite_area() 
    IO.puts(result)
  end

  test "part two" do
    # IO.puts()
  end
end
