defmodule Diamond do
  @doc """
  Given a letter, it prints a diamond starting with 'A',
  with the supplied letter at the widest point.
  """
  @spec build_shape(char) :: String.t()
  def build_shape(?A), do: "A\n"

  def build_shape(letter) do
    up_to_letter = for ch <- ?A..letter, do: row(ch, letter)
    after_letter = for ch <- (letter - 1)..?A, do: row(ch, letter)

    List.flatten([up_to_letter, after_letter]) |> Enum.join()
  end

  defp row(?A, dest) do
    padding = dest - ?A

    Enum.join([
      List.duplicate(" ", padding),
      [?A],
      List.duplicate(" ", padding),
      "\n"
    ])
  end

  defp row(ch, dest) do
    outer = dest - ch
    inner = (ch - ?A) * 2 - 1

    Enum.join([
      List.duplicate(" ", outer),
      [ch],
      List.duplicate(" ", inner),
      [ch],
      List.duplicate(" ", outer),
      "\n"
    ])
  end
end
