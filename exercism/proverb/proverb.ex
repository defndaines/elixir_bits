defmodule Proverb do
  @doc """
  Generate a proverb from a list of strings.
  """
  @spec recite(strings :: [String.t()]) :: String.t()
  def recite([]), do: ""
  def recite([item | _] = strings), do: verse(strings) <> all_for(item)

  defp all_for(string), do: "And all for the want of a #{string}.\n"

  defp verse([wanted, lost | _] = strings) do
    "For want of a #{wanted} the #{lost} was lost.\n" <> verse(tl(strings))
  end

  defp verse(_), do: ""
end
