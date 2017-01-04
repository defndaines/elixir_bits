defmodule Anagram do
  @doc """
  Returns all candidates that are anagrams of, but not equal to, 'base'.
  """
  @spec match(String.t, [String.t]) :: [String.t]
  def match(base, candidates) do
    lower = String.downcase(base)
    letters = lower |> String.graphemes |> Enum.sort
    Enum.filter(candidates, &(anagram?(lower, letters, &1)))
  end

  defp anagram?(base, base_letters, word) do
    lower = String.downcase(word)
    base != lower && base_letters == (lower |> String.graphemes |> Enum.sort)
  end
end
