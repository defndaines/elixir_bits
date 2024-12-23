defmodule Sublist do
  @doc """
  Returns whether the first list is a sublist or a superlist of the second list
  and if not whether it is equal or unequal to the second list.
  """
  def compare(a, a), do: :equal
  def compare([], _), do: :sublist
  def compare(_, []), do: :superlist

  def compare(a, b) when length(a) > length(b) do
    do_compare(a, b, :superlist)
  end

  def compare(a, b) when length(b) > length(a) do
    do_compare(b, a, :sublist)
  end

  def compare(_, _), do: :unequal

  defp do_compare(a, b, success) do
    if Enum.any?(Enum.chunk(a, length(b), 1), &(&1 === b)) do
      success
    else
      :unequal
    end
  end
end
