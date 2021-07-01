defmodule Bowling do
  @doc """
    Creates a new game of bowling that can be used to store the results of
    the game
  """

  @spec start() :: any
  def start, do: {1, [], []}

  @doc """
    Records the number of pins knocked down on a single roll. Returns `any`
    unless there is something wrong with the given number of pins, in which
    case it returns a helpful message.
  """

  @spec roll(any, integer) :: any | String.t()
  def roll(_, pins) when pins < 0, do: {:error, "Negative roll is invalid"}
  def roll(_, pins) when pins > 10, do: {:error, "Pin count exceeds pins on the lane"}
  # A strike or spare in frame 10 stays in the frame for fill rolls.
  def roll({10, [], rolls}, 10), do: {10, [10], [10 | rolls]}
  def roll({10, [10], rolls}, pins), do: {10, [10, pins], [pins | rolls]}
  def roll({10, [10, 10], rolls}, pins), do: {10, :done, [pins | rolls]}

  def roll({10, [10, n], _}, pins) when pins + n > 10 do
    {:error, "Pin count exceeds pins on the lane"}
  end

  def roll({10, [10, _], rolls}, pins), do: {10, :done, [pins | rolls]}

  def roll({10, [n], _}, pins) when pins + n > 10 do
    {:error, "Pin count exceeds pins on the lane"}
  end

  def roll({10, [n], rolls}, pins) when pins + n < 10, do: {10, :done, [pins | rolls]}
  def roll({10, [n], rolls}, pins), do: {10, [n, pins], [pins | rolls]}
  def roll({10, [m, n], rolls}, pins) when n + m == 10, do: {10, :done, [pins | rolls]}
  def roll({frame, [], rolls}, 10) when frame < 10, do: {frame + 1, [], [10 | rolls]}
  def roll({frame, [], rolls}, pins), do: {frame, [pins], [pins | rolls]}

  def roll({_, [n], _}, pins) when pins + n > 10 do
    {:error, "Pin count exceeds pins on the lane"}
  end

  def roll({frame, [_], rolls}, pins), do: {frame + 1, [], [pins | rolls]}
  def roll({10, _, _}, _), do: {:error, "Cannot roll after game is over"}

  @doc """
    Returns the score of a given game of bowling if the game is complete.
    If the game isn't complete, it returns a helpful message.
  """

  @spec score(any) :: integer | String.t()
  def score({10, :done, rolls}) do
    do_score(Enum.reverse(rolls), 0)
  end

  def score(_), do: {:error, "Score cannot be taken until the end of the game"}

  defp do_score([], acc), do: acc
  defp do_score([_], acc), do: acc
  defp do_score([10, r1, r2], acc), do: acc + 10 + r1 + r2

  defp do_score([10 | rest], acc) do
    do_score(rest, acc + 10 + Enum.sum(Enum.take(rest, 2)))
  end

  defp do_score([r1, r2 | rest], acc) do
    case r1 + r2 do
      10 -> do_score(rest, acc + 10 + hd(rest))
      _ -> do_score(rest, acc + r1 + r2)
    end
  end
end
