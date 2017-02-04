defmodule Change do
  @doc """
    Determine the least number of coins to be given to the user such
    that the sum of the coins' value would equal the correct amount of change.
    It returns :error if it is not possible to compute the right amount of coins.
    Otherwise returns the tuple {:ok, map_of_coins}

    ## Examples

      iex> Change.generate(3, [5, 10, 15])
      :error

      iex> Change.generate(18, [1, 5, 10])
      {:ok, %{1 => 3, 5 => 1, 10 => 1}}
  """
  @spec generate(integer, list) :: {:ok, map} | :error
  def generate(_amount, []), do: :error
  def generate(amount, [smallest | _]) when amount < smallest, do: :error
  def generate(amount, values) do
    coins = Map.new(values, &({&1, 0}))
    {_len, solution} = solution_tree(0, [], amount, values)
                       |> List.flatten
                       |> Enum.min_by(&(elem(&1, 0)))
    {:ok, Map.merge(coins, Map.new(solution))}
  end

  defp solution_tree(coins, path, 0, _), do: {coins, path}
  defp solution_tree(coins, path, amount, values) do
    for coin <- values, coin <= amount do
      num = div(amount, coin)
      solution_tree(coins + num, [{coin, num} | path], rem(amount, coin), values)
    end
  end

end
