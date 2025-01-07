defmodule WordSearch do
  defmodule Location do
    defstruct [:from, :to]

    @type t :: %Location{
            from: %{row: integer, column: integer},
            to: %{row: integer, column: integer}
          }
  end

  @doc """
  Find the start and end positions of words in a grid of letters.
  Row and column positions are 1 indexed.
  """
  @spec search(grid :: String.t(), words :: [String.t()]) :: %{String.t() => nil | Location.t()}
  def search(grid, words) do
    by_position =
      for {str, row} <- grid |> String.split() |> Enum.with_index(),
          {ch, col} <- str |> String.graphemes() |> Enum.with_index(),
          into: %{} do
        {{col + 1, row + 1}, ch}
      end

    by_letter =
      Enum.reduce(by_position, %{}, fn {k, v}, acc -> Map.update(acc, v, [k], &[k | &1]) end)

    Map.new(words, &{&1, do_search(&1, by_position, by_letter)})
  end

  defp do_search(word, by_position, by_letter) do
    [x, y | _] = graphemes = String.graphemes(word)

    by_letter
    |> Map.get(x, [])
    |> Enum.reduce_while(nil, fn pos, acc ->
      leads = neighbors(pos, y, by_position)

      case follow_leads(graphemes, by_position, pos, leads) do
        nil -> {:cont, acc}
        location -> {:halt, location}
      end
    end)
  end

  defp neighbors({col, row}, ch, lookup) do
    for c <- (col - 1)..(col + 1),
        r <- (row - 1)..(row + 1),
        pos = {c, r},
        pos != {col, row},
        lookup[pos] == ch do
      pos
    end
  end

  defp follow_leads(_, _, _, []), do: nil

  defp follow_leads(word, lookup, {col_from, row_from} = origin, [{col, row} | rest]) do
    col_step = col - col_from
    row_step = row - row_from

    positions =
      origin
      |> Stream.iterate(fn {c, r} -> {c + col_step, r + row_step} end)
      |> Enum.take(length(word))

    if word == Enum.map(positions, &lookup[&1]) do
      {col_to, row_to} = List.last(positions)
      %Location{from: %{column: col_from, row: row_from}, to: %{column: col_to, row: row_to}}
    else
      follow_leads(word, lookup, origin, rest)
    end
  end
end
