defmodule RNATranscription do
  @doc """
  Transcribes a character list representing DNA nucleotides to RNA

  ## Examples

  iex> RNATranscription.to_rna('ACTG')
  'UGAC'
  """
  @spec to_rna([char]) :: [char]
  def to_rna(dna) do
    do_rna(dna, '')
  end

  defp do_rna('', acc), do: acc
  defp do_rna('G' ++ tail, acc), do: do_rna(tail, acc ++ 'C')
  defp do_rna('C' ++ tail, acc), do: do_rna(tail, acc ++ 'G')
  defp do_rna('T' ++ tail, acc), do: do_rna(tail, acc ++ 'A')
  defp do_rna('A' ++ tail, acc), do: do_rna(tail, acc ++ 'U')
end
