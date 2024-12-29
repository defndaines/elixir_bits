defmodule Minesweeper do
  @doc """
  Annotate empty spots next to mines with the number of mines next to them.
  """
  @spec annotate([String.t()]) :: [String.t()]
  def annotate(board) when length(board) > 0 do
    positions =
      for {row, y} <- Enum.with_index(board),
          {v, x} <- row |> String.graphemes() |> Enum.with_index(),
          into: %{} do
        {{x, y}, v}
      end

    if Enum.empty?(positions) do
      board
    else
      counts =
        Map.new(positions, fn
          {pos, "*"} -> {pos, "*"}
          {pos, " "} -> {pos, count(positions, pos)}
        end)

      for y <- 0..(length(board) - 1) do
        for(
          x <- 0..(String.length(hd(board)) - 1),
          do: Map.get(counts, {x, y})
        )
        |> to_string()
      end
    end
  end

  def annotate(garbage), do: garbage

  defp count(positions, {x, y}) do
    for a <- (x - 1)..(x + 1),
        b <- (y - 1)..(y + 1),
        {a, b} != {x, y},
        "*" == Map.get(positions, {a, b}),
        reduce: 0 do
      acc -> 1 + acc
    end
    |> count_or_empty()
  end

  defp count_or_empty(0), do: " "
  defp count_or_empty(n), do: to_string(n)
end
