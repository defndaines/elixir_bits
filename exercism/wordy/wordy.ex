defmodule Wordy do
  @doc """
  Calculate the math problem in the sentence.
  """
  @spec answer(String.t()) :: integer
  def answer(question) do
    question
    |> String.trim_trailing("?")
    |> String.split()
    |> Enum.drop(2)
    |> Enum.map(&maybe_to_integer/1)
    |> parse()
  end

  defp maybe_to_integer(str) do
    case Integer.parse(str) do
      {n, ""} -> n
      _ -> str
    end
  end

  defp parse([n]), do: n

  defp parse([n, "plus", m | rest]) when is_integer(n) and is_integer(m) do
    parse([n + m | rest])
  end

  defp parse([n, "minus", m | rest]) when is_integer(n) and is_integer(m) do
    parse([n - m | rest])
  end

  defp parse([n, "multiplied", "by", m | rest]) when is_integer(n) and is_integer(m) do
    parse([n * m | rest])
  end

  defp parse([n, "divided", "by", m | rest]) when is_integer(n) and is_integer(m) do
    parse([div(n, m) | rest])
  end

  defp parse(_), do: raise(ArgumentError)
end
