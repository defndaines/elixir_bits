defmodule OcrNumbers do
  @numbers %{
    [" _ ", "| |", "|_|", "   "] => "0",
    ["   ", "  |", "  |", "   "] => "1",
    [" _ ", " _|", "|_ ", "   "] => "2",
    [" _ ", " _|", " _|", "   "] => "3",
    ["   ", "|_|", "  |", "   "] => "4",
    [" _ ", "|_ ", " _|", "   "] => "5",
    [" _ ", "|_ ", "|_|", "   "] => "6",
    [" _ ", "  |", "  |", "   "] => "7",
    [" _ ", "|_|", "|_|", "   "] => "8",
    [" _ ", "|_|", " _|", "   "] => "9"
  }

  @doc """
  Given a 3 x 4 grid of pipes, underscores, and spaces, determine which number is represented, or
  whether it is garbled.
  """
  @spec convert([String.t()]) :: {:ok, String.t()} | {:error, String.t()}
  def convert(input) do
    cond do
      rem(length(input), 4) > 0 -> {:error, "invalid line count"}
      input |> hd() |> String.length() |> rem(3) > 0 -> {:error, "invalid column count"}
      true -> {:ok, input |> Enum.chunk_every(4) |> Enum.map_join(",", &do_convert/1)}
    end
  end

  defp triplets(lines) do
    lines |> String.graphemes() |> Enum.chunk_every(3) |> Enum.map(&to_string/1)
  end

  defp do_convert(input) do
    input
    |> Enum.map(&triplets/1)
    |> Enum.zip_with(& &1)
    |> Enum.map_join("", &Map.get(@numbers, &1, "?"))
  end
end
