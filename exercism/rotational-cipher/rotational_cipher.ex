defmodule RotationalCipher do
  @doc """
  Given a plaintext and amount to shift by, return a rotated string.

  Example:
  iex> RotationalCipher.rotate("Attack at dawn", 13)
  "Nggnpx ng qnja"
  """
  @spec rotate(text :: String.t(), shift :: integer) :: String.t()
  def rotate(text, shift) do
    text |> String.to_charlist() |> Enum.map(&rot(&1, shift)) |> to_string()
  end

  defp rot(ch, shift) when ch in ?A..?Z, do: ?A + rem(ch - ?A + shift, 26)
  defp rot(ch, shift) when ch in ?a..?z, do: ?a + rem(ch - ?a + shift, 26)
  defp rot(ch, _), do: ch
end
