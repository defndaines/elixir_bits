defmodule RNATranscription do
  @doc """
  Transcribes a character list representing DNA nucleotides to RNA

  ## Examples

  iex> RNATranscription.to_rna('ACTG')
  'UGAC'
  """
  @spec to_rna([char]) :: [char]
  def to_rna(dna) do
    do_rna(dna, ~c"")
  end

  defp do_rna(~c"", acc), do: acc
  defp do_rna(~c"G" ++ tail, acc), do: do_rna(tail, acc ++ ~c"C")
  defp do_rna(~c"C" ++ tail, acc), do: do_rna(tail, acc ++ ~c"G")
  defp do_rna(~c"T" ++ tail, acc), do: do_rna(tail, acc ++ ~c"A")
  defp do_rna(~c"A" ++ tail, acc), do: do_rna(tail, acc ++ ~c"U")
end
