defmodule Isogram do
  @doc """
  Determines if a word or sentence is an isogram
  """
  @spec isogram?(String.t) :: boolean
  def isogram?(sentence) do
    chars = Regex.replace(~r/\P{L}/u, sentence, "")
            |> String.graphemes
    chars == Enum.uniq(chars)
  end
end
