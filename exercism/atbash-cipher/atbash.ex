defmodule Atbash do
  @doc """
  Encode a given plaintext to the corresponding ciphertext

  ## Examples

  iex> Atbash.encode("completely insecure")
  "xlnko vgvob rmhvx fiv"
  """
  @spec encode(String.t()) :: String.t()
  def encode(plaintext) do
    plaintext
    |> String.downcase()
    |> do_encode()
    |> Enum.chunk_every(5)
    |> Enum.map_join(" ", &to_string/1)
  end

  @spec decode(String.t()) :: String.t()
  def decode(cipher), do: cipher |> do_encode() |> to_string()

  defp do_encode([]), do: []
  defp do_encode(ch) when is_binary(ch), do: ch |> String.to_charlist() |> do_encode()
  defp do_encode([ch | rest]) when ch in ?a..?z, do: [?a + ?z - ch | do_encode(rest)]
  defp do_encode([ch | rest]) when ch in ?0..?9, do: [ch | do_encode(rest)]
  defp do_encode([_ | rest]), do: do_encode(rest)
end
