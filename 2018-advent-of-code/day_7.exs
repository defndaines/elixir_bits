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
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> Regex.run(@line_regex, line, [capture: :all_but_first]) end)
  end

  def map_instructions(input) do
    graph = :digraph.new
    all_vertices = input |> Enum.reduce(&Enum.concat/2) |> Enum.uniq
    for ch <- all_vertices, do: :digraph.add_vertex(graph, ch)
    for [from, to] <- input, do: :digraph.add_edge(graph, from, to)
    graph
  end

  defp step(_graph, acc, _visited, []), do: acc
  defp step(graph, acc, visited, [node | free]) do
    visit_set = MapSet.put(visited, node)
    new_neighbors = graph
                    |> :digraph.out_neighbours(node)
                    |> Enum.filter(fn v -> :digraph.in_neighbours(graph, v) |> MapSet.new |> MapSet.subset?(visit_set) end)
    free_now = free ++ new_neighbors |> Enum.sort |> Enum.dedup
    step(graph, acc <> node, visit_set, free_now)
  end

  @doc """
  Determine the order of instructions. If more than one step is ready, choose
  the step which is first alphabetically.
  """
  def order_instructions(input) do
    graph = map_instructions(input)
    starting = graph
               |> :digraph.vertices
               |> Enum.filter(fn v -> :digraph.in_neighbours(graph, v) == [] end)
               |> Enum.sort
    step(graph, "", MapSet.new, starting)
  end
end

ExUnit.start()

defmodule Day7Test do
  use ExUnit.Case

  import Day7

  test "input to list" do
    input = input_to_list()

    [["U", "A"],
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
    result = order_instructions(input_to_list())
    IO.puts(result)
  end

  test "part two" do
    # IO.puts()
  end
end
