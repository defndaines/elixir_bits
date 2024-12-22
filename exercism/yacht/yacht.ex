defmodule Yacht do
  @type category ::
          :ones
          | :twos
          | :threes
          | :fours
          | :fives
          | :sixes
          | :full_house
          | :four_of_a_kind
          | :little_straight
          | :big_straight
          | :choice
          | :yacht

  @doc """
  Calculate the score of 5 dice using the given category's scoring method.
  """
  @spec score(category :: category(), dice :: [integer]) :: integer
  def score(:yacht, [x, x, x, x, x]), do: 50
  def score(:choice, dice), do: Enum.sum(dice)
  def score(:ones, dice), do: dice |> Enum.filter(&(&1 == 1)) |> Enum.sum()
  def score(:twos, dice), do: dice |> Enum.filter(&(&1 == 2)) |> Enum.sum()
  def score(:threes, dice), do: dice |> Enum.filter(&(&1 == 3)) |> Enum.sum()
  def score(:fours, dice), do: dice |> Enum.filter(&(&1 == 4)) |> Enum.sum()
  def score(:fives, dice), do: dice |> Enum.filter(&(&1 == 5)) |> Enum.sum()
  def score(:sixes, dice), do: dice |> Enum.filter(&(&1 == 6)) |> Enum.sum()
  def score(category, dice), do: do_score(category, Enum.sort(dice))

  defp do_score(:four_of_a_kind, [x, x, x, x, _]), do: x * 4
  defp do_score(:four_of_a_kind, [_, x, x, x, x]), do: x * 4
  defp do_score(:full_house, [x, x, y, y, y] = dice) when x != y, do: Enum.sum(dice)
  defp do_score(:full_house, [x, x, x, y, y] = dice) when x != y, do: Enum.sum(dice)
  defp do_score(:little_straight, [1, 2, 3, 4, 5]), do: 30
  defp do_score(:big_straight, [2, 3, 4, 5, 6]), do: 30
  defp do_score(_, _), do: 0
end
