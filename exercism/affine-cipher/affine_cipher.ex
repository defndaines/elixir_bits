defmodule AffineCipher do
  @typedoc """
  A type for the encryption key
  """
  @type key() :: %{a: integer, b: integer}

  @doc """
  Encode an encrypted message using a key
  """
  @spec encode(key :: key(), message :: String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def encode(key, message) do
    if Integer.gcd(key.a, 26) == 1 do
      {:ok,
       message
       |> String.downcase()
       |> String.to_charlist()
       |> translate(encoder(key))
       |> Enum.chunk_every(5)
       |> Enum.join(" ")}
    else
      {:error, "a and m must be coprime."}
    end
  end

  @doc """
  Decode an encrypted message using a key
  """
  @spec decode(key :: key(), encrypted :: String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def decode(key, encrypted) do
    if Integer.gcd(key.a, 26) == 1 do
      {:ok,
       encrypted
       |> String.to_charlist()
       |> translate(decoder(key.b, mmi(key.a)))
       |> to_string()}
    else
      {:error, "a and m must be coprime."}
    end
  end

  defp encoder(%{a: a, b: b}), do: &(rem(a * (&1 - ?a) + b, 26) + ?a)

  defp decoder(b, inverse), do: &(Integer.mod(inverse * (&1 - ?a - b), 26) + ?a)

  defp mmi(a, i \\ 0)
  defp mmi(a, i) when rem(a * i, 26) == 1, do: i
  defp mmi(a, i), do: mmi(a, i + 1)

  defp translate([], _), do: []
  defp translate([ch | rest], fun) when ch in ?a..?z, do: [fun.(ch) | translate(rest, fun)]
  defp translate([ch | rest], fun) when ch in ?0..?9, do: [ch | translate(rest, fun)]
  defp translate([_ | rest], fun), do: translate(rest, fun)
end
