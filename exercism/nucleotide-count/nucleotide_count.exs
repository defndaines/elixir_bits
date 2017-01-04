defmodule NucleotideCount do
  @nucleotides [?A, ?C, ?G, ?T]

  @doc """
  Counts individual nucleotides in a NucleotideCount strand.

  ## Examples

  iex> NucleotideCount.count('AATAA', ?A)
  4

  iex> NucleotideCount.count('AATAA', ?T)
  1
  """
  @spec count([char], char) :: non_neg_integer
  def count(strand, nucleotide) when nucleotide in @nucleotides do
    histogram(strand)[nucleotide]
  end
  def count(_strand, _nucleotide), do: raise ArgumentError

  @doc """
  Returns a summary of counts by nucleotide.

  ## Examples

  iex> NucleotideCount.histogram('AATAA')
  %{?A => 4, ?T => 1, ?C => 0, ?G => 0}
  """
  @spec histogram([char]) :: map
  def histogram(strand) do
    Enum.reduce(strand,
                %{?A => 0, ?T => 0, ?C => 0, ?G => 0},
                &update_or_throw/2)
  end

  defp update_or_throw(c, map) do
    if Map.has_key?(map, c) do
      update_in(map[c], &(&1 + 1))
    else
      raise ArgumentError, message: "Unrecognized base: " <> c
    end
  end
end