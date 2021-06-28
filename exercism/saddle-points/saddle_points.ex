defmodule SaddlePoints do
  @doc """
  Parses a string representation of a matrix
  to a list of rows
  """
  @spec rows(String.t()) :: [[integer]]
  def rows(str) do
    str
    |> String.split("\n")
    |> Enum.map(&to_int_list/1)
  end

  @doc """
  Parses a string representation of a matrix
  to a list of columns
  """
  @spec columns(String.t()) :: [[integer]]
  def columns(str) do
    str
    |> rows()
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  @doc """
  Calculates all the saddle points from a string
  representation of a matrix
  """
  @spec saddle_points(String.t()) :: [{integer, integer}]
  def saddle_points(str) do
    peaks = pull(rows(str), &high_points/2)
    troughs = pull(columns(str), &low_points/2)
    MapSet.intersection(peaks, troughs) |> MapSet.to_list()
  end

  defp to_int_list(str) do
    str
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp pull(list, fun) do
    candidates =
      for i <- 0..(length(list) - 1) do
        list
        |> Enum.at(i)
        |> Enum.with_index()
        |> fun.(i)
      end

    candidates |> List.flatten() |> MapSet.new()
  end

  defp high_points(row, x) do
    max = row |> Enum.max_by(&by_value/1) |> elem(0)

    Enum.filter(row, fn {v, _} -> v == max end)
    |> Enum.map(fn {_, y} -> {x, y} end)
  end

  defp low_points(column, y) do
    min = column |> Enum.min_by(&by_value/1) |> elem(0)

    Enum.filter(column, fn {v, _} -> v == min end)
    |> Enum.map(fn {_, x} -> {x, y} end)
  end

  defp by_value({v, _}), do: v
end
