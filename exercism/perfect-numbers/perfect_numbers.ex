defmodule PerfectNumbers do
  @doc """
  Determine the aliquot sum of the given `number`, by summing all the factors
  of `number`, aside from `number` itself.

  Based on this sum, classify the number as:

  :perfect if the aliquot sum is equal to `number`
  :abundant if the aliquot sum is greater than `number`
  :deficient if the aliquot sum is less than `number`
  """
  @spec classify(number :: integer) :: {:ok, atom} | {:error, String.t()}
  def classify(number) when number < 1 do
    {:error, "Classification is only possible for natural numbers."}
  end

  def classify(1), do: {:ok, :deficient}

  def classify(number) do
    case number |> factors() |> Enum.sum() do
      ^number -> {:ok, :perfect}
      sum when sum > number -> {:ok, :abundant}
      sum when sum < number -> {:ok, :deficient}
    end
  end

  defp factors(number), do: Enum.filter(1..div(number, 2), &(rem(number, &1) == 0))
end
