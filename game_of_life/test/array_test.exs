defmodule ArrayTest do
  use ExUnit.Case

  test "convert list to array" do
    list = [[0, 1, 0], [2, 0, 0], [0, 0, 0]]
    array = Array.from_list(list)

    assert Array.get(array, {0, 0}) == 0
    assert Array.get(array, {0, 1}) == 1
    assert Array.get(array, {1, 0}) == 2
  end

  test "round robin conversion list->array->list" do
    list = [[0, 1, 0], [2, 0, 0], [0, 0, 0]]

    array = Array.from_list(list)
    assert Array.to_list(array) == list
  end

  test "in bounds of array" do
    list = [[0, 1, 0], [2, 0, 0]]
    array = Array.from_list(list)

    assert Array.in_bounds?(array, {0, 0})
    assert Array.in_bounds?(array, {0, 2})
    assert Array.in_bounds?(array, {1, 2})

    refute Array.in_bounds?(array, {2, 0})
    refute Array.in_bounds?(array, {0, 3})
  end

  test "neighbors returns number of live neighbors" do
    grid = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
    array = Array.from_list(grid)

    assert Array.neighbors(array, {1, 1}) == 2
    assert Array.neighbors(array, {0, 0}) == 1
    assert Array.neighbors(array, {2, 2}) == 1
  end
end
