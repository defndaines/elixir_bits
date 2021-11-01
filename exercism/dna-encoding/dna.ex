defmodule DNA do
  def encode_nucleotide(?\s), do: 0b0000
  def encode_nucleotide(?A), do: 0b0001
  def encode_nucleotide(?C), do: 0b0010
  def encode_nucleotide(?G), do: 0b0100
  def encode_nucleotide(?T), do: 0b1000

  def decode_nucleotide(0b0000), do: ?\s
  def decode_nucleotide(0b0001), do: ?A
  def decode_nucleotide(0b0010), do: ?C
  def decode_nucleotide(0b0100), do: ?G
  def decode_nucleotide(0b1000), do: ?T

  def encode(dna, acc \\ "")
  def encode('', acc), do: acc

  def encode([base | rest], acc) do
    encode(rest, <<acc::bitstring, encode_nucleotide(base)::4>>)
  end

  def decode(dna, acc \\ '')
  def decode("", acc), do: acc

  def decode(<<base::4, rest::bitstring>>, acc) do
    decode(rest, acc ++ [decode_nucleotide(base)])
  end
end
