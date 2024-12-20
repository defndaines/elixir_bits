defmodule Say do
  @ones ~w(X one two three four five six seven eight nine)
  @teens ~w(ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen)
  @tens ~w(X X twenty thirty forty fifty sixty seventy eighty ninety)

  @doc """
  Translate a positive integer into English.
  """
  @spec in_english(integer) :: {atom, String.t()}
  def in_english(number) when number < 0 or number > 999_999_999_999 do
    {:error, "number is out of range"}
  end

  def in_english(0), do: {:ok, "zero"}
  def in_english(number), do: {:ok, number |> Integer.digits() |> english() |> String.trim()}

  defp english([]), do: ""
  defp english([0 | rest]), do: english(rest)
  defp english(digits) when length(digits) > 9, do: chunk(digits, 9, "billion")
  defp english(digits) when length(digits) > 6, do: chunk(digits, 6, "million")
  defp english(digits) when length(digits) > 3, do: chunk(digits, 3, "thousand")
  defp english(digits) when length(digits) > 2, do: chunk(digits, 2, "hundred")
  defp english([1, n]), do: Enum.at(@teens, n)
  defp english([n, 0]), do: Enum.at(@tens, n)
  defp english([n, rest]), do: "#{Enum.at(@tens, n)}-#{english(rest)}"
  defp english([n]), do: english(n)
  defp english(n), do: Enum.at(@ones, n)

  defp chunk(digits, len, unit) do
    this_bit = length(digits) - len
    "#{english(Enum.take(digits, this_bit))} #{unit} #{english(Enum.drop(digits, this_bit))}"
  end
end
