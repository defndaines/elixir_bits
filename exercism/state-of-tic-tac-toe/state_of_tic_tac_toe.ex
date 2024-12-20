defmodule StateOfTicTacToe do
  @x "X"
  @o "O"

  @doc """
  Determine the state a game of tic-tac-toe where X starts.
  """
  @spec game_state(board :: String.t()) :: {:ok, :win | :ongoing | :draw} | {:error, String.t()}
  def game_state(board) do
    state = board |> String.graphemes() |> Enum.reject(&(&1 == "\n"))
    x_count = state |> Enum.filter(&(&1 == @x)) |> Enum.count()
    o_count = state |> Enum.filter(&(&1 == @o)) |> Enum.count()

    cond do
      x_count > o_count + 1 ->
        {:error, "Wrong turn order: X went twice"}

      o_count > x_count ->
        {:error, "Wrong turn order: O started"}

      win?(@x, state) and win?(@o, state) ->
        {:error, "Impossible board: game should have ended after the game was won"}

      win?(@x, state) or win?(@o, state) ->
        {:ok, :win}

      Enum.member?(state, ".") ->
        {:ok, :ongoing}

      true ->
        {:ok, :draw}
    end
  end

  defp win?(ch, [ch, ch, ch, _, _, _, _, _, _]), do: true
  defp win?(ch, [_, _, _, ch, ch, ch, _, _, _]), do: true
  defp win?(ch, [_, _, _, _, _, _, ch, ch, ch]), do: true
  defp win?(ch, [ch, _, _, ch, _, _, ch, _, _]), do: true
  defp win?(ch, [_, ch, _, _, ch, _, _, ch, _]), do: true
  defp win?(ch, [_, _, ch, _, _, ch, _, _, ch]), do: true
  defp win?(ch, [ch, _, _, _, ch, _, _, _, ch]), do: true
  defp win?(ch, [_, _, ch, _, ch, _, ch, _, _]), do: true
  defp win?(_, _), do: false
end
