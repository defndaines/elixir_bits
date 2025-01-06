defmodule BookStore do
  @typedoc "A book is represented by its number in the 5-book series"
  @type book :: 1 | 2 | 3 | 4 | 5

  @doc """
  Calculate lowest price (in cents) for a shopping basket containing books.
  """
  @spec total(basket :: [book]) :: integer
  def total(basket), do: basket |> bundle() |> second_guess() |> price_bundles()

  defp bundle(basket, acc \\ [[]])
  defp bundle([], acc), do: acc

  defp bundle([book | basket], acc) do
    {already, potential} = Enum.split_while(acc, &Enum.member?(&1, book))
    bundle(basket, add_for_cheapest(already, potential, book))
  end

  defp add_for_cheapest(already, [], book), do: already ++ [[book]]

  defp add_for_cheapest(already, potential, book) do
    potential
    |> Enum.with_index(fn e, i -> already ++ List.replace_at(potential, i, [book | e]) end)
    |> Enum.min_by(&price_bundles/1)
  end

  defp second_guess(bundles) do
    fives = Enum.filter(bundles, &(length(&1) == 5))
    threes = Enum.filter(bundles, &(length(&1) == 3))

    if Enum.empty?(fives) or Enum.empty?(threes) do
      bundles
    else
      [five | _] = fives
      [three | _] = threes
      [x | _] = five -- three
      ((bundles -- [five]) -- [three]) ++ [five -- [x]] ++ [[x | three]]
    end
  end

  defp price_bundles(bundles), do: bundles |> Enum.map(&price_bundle/1) |> Enum.sum()

  defp price_bundle(bundle), do: bundle |> length() |> rate()

  defp rate(0), do: 0
  defp rate(1), do: 800
  defp rate(2), do: 1520
  defp rate(3), do: 2160
  defp rate(4), do: 2560
  defp rate(5), do: 3000
end
