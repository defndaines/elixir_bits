defmodule Queens do
  @type t :: %Queens{black: {integer, integer}, white: {integer, integer}}
  defstruct [:white, :black]

  @doc """
  Creates a new set of Queens
  """
  @spec new(Keyword.t()) :: Queens.t()
  def new(opts \\ []) do
    black = Keyword.get(opts, :black)
    white = Keyword.get(opts, :white)
    if invalid_queen?(black), do: raise ArgumentError, message: "invalid postition"
    if invalid_queen?(white), do: raise ArgumentError, message: "invalid postition"
    if black == white, do: raise ArgumentError, message: "cannot occupy same space"
    %Queens{black: black, white: white}
  end

  @doc """
  Gives a string representation of the board with
  white and black queen locations shown
  """
  @spec to_string(Queens.t()) :: String.t()
  def to_string(%{black: black, white: white}) do
    board = for x <- 0..7, y <- 0..7, into: %{}, do: {{x, y}, "_"}

    with_pieces = Map.put(board, black, "B") |> Map.put(white, "W")

    str_list = for x <- 0..7 do
      row = for y <- 0..7, do: Map.get(with_pieces, {x, y})
      Enum.join(row, " ")
    end

    Enum.join(str_list, "\n")
  end

  @doc """
  Checks if the queens can attack each other
  """
  @spec can_attack?(Queens.t()) :: boolean
  def can_attack?(%{black: {bx, by}, white: {wx, wy}}) do
    bx == wx or by == wy or abs(bx - wx) == abs(by - wy)
  end
  def can_attack?(_), do: false

  defp invalid_queen?({x, y}), do: x < 0 or x >= 8 or y < 0 or y >= 8
  defp invalid_queen?(_), do: nil
end
