defmodule Darts do
  @type position :: {number, number}

  @doc """
  Calculate the score of a single dart hitting a target
  """
  @spec score(position) :: integer
  def score({x, y}) do
    distance = :math.sqrt(x ** 2 + y ** 2)

    cond do
      distance > 10 -> 0
      distance > 5 -> 1
      distance > 1 -> 5
      true -> 10
    end
  end
end
