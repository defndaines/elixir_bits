defmodule LifeTest do
  use ExUnit.Case

  describe "applying rules to array" do
    test "not enough neighbors leads to death" do
      grid = [[1, 0, 0], [0, 1, 0], [0, 0, 0]]
      array = Array.from_list(grid)

      assert Life.apply_rule(array, {1, 1}) == 0
    end

    test "too many neighbors leads to death" do
      grid = [[1, 1, 1], [1, 1, 0], [0, 0, 0]]
      array = Array.from_list(grid)

      assert Life.apply_rule(array, {1, 1}) == 0
    end

    test "two neighbors keeps alive" do
      grid = [[1, 1, 0], [0, 1, 0], [0, 0, 0]]
      array = Array.from_list(grid)

      assert Life.apply_rule(array, {1, 1}) == 1
    end

    test "three neighbors keeps alive" do
      grid = [[1, 1, 1], [0, 1, 0], [0, 0, 0]]
      array = Array.from_list(grid)

      assert Life.apply_rule(array, {1, 1}) == 1
    end

    test "three live neighbors brings to life" do
      grid = [[1, 1, 1], [0, 0, 0], [0, 0, 0]]
      array = Array.from_list(grid)

      assert Life.apply_rule(array, {1, 1}) == 1
    end
  end

  test "initialize game with grid" do
    grid = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
    game = Life.start(grid)

    try do
      assert Life.state(game) == grid
    after
      Life.stop(game)
    end
  end

  defp age_and_get(game, {x, y}) do
    Life.age(game)
    Life.state(game) |> Enum.at(x) |> Enum.at(y)
  after
    Life.stop(game)
  end

  describe "Rule: Any live cell with two or three live neighbours survives." do
    test "{1, 1} has two live neighbors" do
      grid = [[1, 1, 0], [0, 1, 0], [0, 0, 0]]
      game = Life.start(grid)

      assert age_and_get(game, {1, 1}) == 1
    end

    test "{1, 1} has three live neighbors" do
      grid = [[1, 1, 0], [1, 1, 0], [0, 0, 0]]
      game = Life.start(grid)

      assert age_and_get(game, {1, 1}) == 1
    end

    @tag :pending
    test "{1, 1} doesn't have enough neighbors" do
      grid = [[1, 0, 0], [0, 1, 0], [0, 0, 0]]
      game = Life.start(grid)

      assert age_and_get(game, {1, 1}) == 0
    end
  end
end
