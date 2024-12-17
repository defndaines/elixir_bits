defmodule Alphametics do
  @type puzzle :: binary
  @type solution :: %{required(?A..?Z) => 0..9}

  @digits [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

  @doc """
  Takes an alphametics puzzle and returns a solution where every letter
  replaced by its number will make a valid equation. Returns `nil` when
  there is no valid solution to the given puzzle.

  ## Examples

      iex> Alphametics.solve("I + BB == ILL")
      %{?I => 1, ?B => 9, ?L => 0}

      iex> Alphametics.solve("A == B")
      nil
  """
  @spec solve(puzzle) :: solution | nil
  def solve(puzzle) do
    [left, right] = String.split(puzzle, " == ")
    terms = left |> String.split(" + ") |> Enum.map(&String.to_charlist/1)
    solution = String.to_charlist(right)
    non_zero = [solution | terms] |> Enum.map(&hd/1) |> Enum.uniq()

    [solution | terms]
    |> List.flatten()
    |> Enum.uniq()
    |> permutations(non_zero)
    |> Enum.find(fn map ->
      to_integer = fn charl -> charl |> Enum.map(&Map.get(map, &1)) |> Integer.undigits() end
      sum = terms |> Enum.map(to_integer) |> Enum.sum()
      sum == to_integer.(solution)
    end)
  end

  defp permutations(letters, non_zero) do
    [head | tail] = letters
    maybe_zero = fn l -> if(Enum.member?(non_zero, l), do: [0], else: []) end
    seed = for n <- @digits, n != 0, do: %{head => n}

    Enum.reduce(tail, seed, fn l, acc ->
      Enum.flat_map(acc, fn map ->
        digits = (@digits -- Map.values(map)) -- maybe_zero.(l)
        for n <- digits -- Map.values(map), do: Map.put(map, l, n)
      end)
    end)
  end
end
