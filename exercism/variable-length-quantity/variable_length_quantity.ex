defmodule VariableLengthQuantity do
  import Bitwise

  @bit_mask 0b1111111

  @doc """
  Encode integers into a bitstring of VLQ encoded bytes
  """
  @spec encode(integers :: [integer]) :: binary
  def encode(integers), do: Enum.map_join(integers, <<>>, &do_encode/1)

  defp do_encode(i, flag \\ 0) do
    if band(i, @bit_mask) == i do
      <<flag::1, i::7>>
    else
      <<do_encode(bsr(i, 7), 1)::binary, flag::1, i::7>>
    end
  end

  @doc """
  Decode a bitstring of VLQ encoded bytes into a series of integers
  """
  @spec decode(bytes :: binary) :: {:ok, [integer]} | {:error, String.t()}
  def decode(bytes, n \\ 0, acc \\ [])

  def decode(<<>>, _, []), do: {:error, "incomplete sequence"}
  def decode(<<>>, _, acc), do: {:ok, acc}

  def decode(<<0::1, value::7, rest::binary>>, n, acc) do
    decode(rest, 0, acc ++ [bsl(n, 7) + value])
  end

  def decode(<<1::1, value::7, rest::binary>>, n, acc) do
    decode(rest, bsl(n, 7) + value, acc)
  end
end
