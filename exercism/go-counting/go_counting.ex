defmodule GoCounting do
  @type position :: {integer, integer}
  @type owner :: %{owner: atom, territory: [position]}
  @type territories :: %{white: [position], black: [position], none: [position]}

  @pieces %{"_" => :none, "B" => :black, "W" => :white}

  @doc """
  Return the owner and territory around a position
  """
  @spec territory(board :: String.t(), position :: position) ::
          {:ok, owner} | {:error, String.t()}
  def territory(board, pos) do
    grid = parse(board)

    if Map.get(grid, pos) do
      {:ok,
       grid
       |> do_territory(pos)
       |> Map.take([:owner, :territory])
       |> Map.update!(:territory, &Enum.sort/1)}
    else
      {:error, "Invalid coordinate"}
    end
  end

  @doc """
  Return all white, black and neutral territories
  """
  @spec territories(board :: String.t()) :: territories
  def territories(board) do
    grid = parse(board)
    open = Enum.reduce(grid, [], fn {k, v}, acc -> if v == :none, do: [k | acc], else: acc end)

    result =
      Enum.reduce(open, %{none: [], black: [], white: [], visited: MapSet.new()}, fn pos, acc ->
        case pos in acc.visited || do_territory(grid, pos) do
          %{owner: owner, territory: territory} ->
            acc
            |> Map.update(owner || :none, territory, &(territory ++ &1))
            |> Map.update(:visited, territory, &MapSet.union(&1, MapSet.new(territory)))

          true ->
            acc
        end
      end)

    Map.take(result, [:none, :black, :white])
  end

  defp parse(board) do
    for {line, y} <- board |> String.split("\n", trim: true) |> Enum.with_index(),
        {v, x} <- line |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      {{x, y}, @pieces[v]}
    end
  end

  defp neighbors({x, y}, grid, context) do
    Enum.filter(
      [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}],
      &(Map.get(grid, &1) && &1 not in context.visited)
    )
  end

  defp do_territory(grid, pos, context \\ %{owner: nil, visited: MapSet.new(), territory: []}) do
    case Map.get(grid, pos) do
      :none ->
        Enum.reduce(
          neighbors(pos, grid, context),
          context
          |> Map.update!(:visited, &MapSet.put(&1, pos))
          |> Map.update!(:territory, &[pos | &1]),
          fn neighbor, acc -> do_territory(grid, neighbor, acc) end
        )

      :black ->
        if Enum.empty?(context.territory) do
          Map.put(context, :owner, :none)
        else
          case context.owner do
            :white -> %{context | owner: :none, visited: MapSet.put(context.visited, pos)}
            :none -> %{context | visited: MapSet.put(context.visited, pos)}
            _ -> %{context | owner: :black, visited: MapSet.put(context.visited, pos)}
          end
        end

      :white ->
        case context.owner do
          :black -> %{context | owner: :none, visited: MapSet.put(context.visited, pos)}
          :none -> %{context | visited: MapSet.put(context.visited, pos)}
          _ -> %{context | owner: :white, visited: MapSet.put(context.visited, pos)}
        end
    end
  end
end
