defmodule Connect do
  @doc """
  Calculates the winner (if any) of a board using "O" as the white player and "X" as the black
  player.
  """
  @spec result_for([String.t()]) :: :none | :black | :white
  def result_for(board) do
    white_edge = length(board) - 1
    black_edge = String.length(hd(board)) - 1

    positions = board |> Enum.map(&String.graphemes/1) |> positions()

    black = Map.get(positions, "X", [])
    black_clusters = black |> Enum.filter(&match?({_, 0}, &1)) |> Enum.map(&connected(&1, black))

    white = Map.get(positions, "O", [])
    white_clusters = white |> Enum.filter(&match?({0, _}, &1)) |> Enum.map(&connected(&1, white))

    cond do
      win?(black_clusters, &match?({_, ^black_edge}, &1)) -> :black
      win?(white_clusters, &match?({^white_edge, _}, &1)) -> :white
      true -> :none
    end
  end

  defp positions(grid) do
    for {row, x} <- Enum.with_index(grid), {v, y} <- Enum.with_index(row), reduce: %{} do
      acc -> if v == ".", do: acc, else: Map.update(acc, v, [{x, y}], &[{x, y} | &1])
    end
  end

  defp connected({x, y}, other) do
    check = other -- [{x, y}]
    excluding = [{x - 1, y - 1}, {x, y}, {x + 1, y + 1}]

    neighbors =
      for m <- (x - 1)..(x + 1),
          n <- (y - 1)..(y + 1),
          {m, n} not in excluding,
          Enum.member?(check, {m, n}) do
        {m, n}
      end

    [{x, y} | Enum.flat_map(neighbors, &connected(&1, check -- neighbors))]
  end

  defp win?(clusters, match_fn) do
    Enum.any?(clusters, fn cluster -> not Enum.empty?(Enum.filter(cluster, match_fn)) end)
  end
end
