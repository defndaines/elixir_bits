defmodule Day7 do
  @moduledoc """
  Solutions to Day 7 of 2018 Advent of Code. The Sum of Its Parts
  https://adventofcode.com/2018/day/7
  """

  @line_regex ~r/Step ([A-Z]) must.* step ([A-Z]) can begin./

  @doc """
  Read a list of steps from a file.

  Example data:
  Step U must be finished before step A can begin.
  Step F must be finished before step Z can begin.
  Step B must be finished before step J can begin.
  """
  def input_to_list() do
    {:ok, input} = File.read("input")
    String.split(input, "\n", trim: true)
    |> Enum.map(fn line -> Regex.run(@line_regex, line, [capture: :all_but_first]) end)
  end

  def map_instructions(input) do
    graph = :digraph.new
    all_vertices = Enum.reduce(input, &Enum.concat/2) |> Enum.uniq
    for ch <- all_vertices, do: :digraph.add_vertex(graph, ch)
    for [from, to] <- input, do: :digraph.add_edge(graph, from, to)
    graph
  end

  def ready_neighbors(graph, node, visited, free) do
    opened = :digraph.out_neighbours(graph, node)
    avail = MapSet.new(free)
    been_there = MapSet.new(visited)
    Enum.filter(opened,
      # in_neigh =  MapSet.new(:digraph.in_neighbours(graph, n))
      #  available? ... MapSet.subset?(in_neigh, been_there)
      fn n -> 

  end

  @doc """
  Determine the order of instructions. If more than one step is ready, choose
  the step which is first alphabetically.
  """
  def order_instructions(input) do
    graph = map_instructions(input)
    vertices = :digraph.vertices(graph)
    starting = Enum.filter(vertices, fn v -> :digraph.in_neighbours(graph, v) == [] end) |> Enum.sort
    [start | rem] = starting
    visited = [start]
    next_options = rem ++ :digraph.out_neighbours(graph, start)

    :digraph.out_neighbours(graph, start)
  end
end

ExUnit.start()

defmodule Day7Test do
  use ExUnit.Case

  import Day7

  test "input to list" do
    input = input_to_list()

    [ ["U", "A"],
      ["F", "Z"],
      ["B", "J"]] = Enum.take(input, 3)
  end

  test "steps" do
    input = [
      ["F", "E"],
      ["A", "B"],
      ["A", "D"],
      ["B", "E"],
      ["C", "F"],
      ["C", "A"],
      ["D", "E"],
    ]

    "CABDFE" = order_instructions(input)
  end

  test "part one" do
    # IO.puts()
  end

  test "part two" do
    # IO.puts()
  end
end
