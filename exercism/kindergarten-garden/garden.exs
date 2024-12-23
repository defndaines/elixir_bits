defmodule Garden do
  @students ~w(alice bob charlie david eve fred
               ginny harriet ileana joseph kincaid larry)a

  @doc """
    Accepts a string representing the arrangement of cups on a windowsill and a
    list with names of students in the class. The student names list does not
    have to be in alphabetical order.

    It decodes that string into the various gardens for each student and returns
    that information in a map.
  """
  @spec info(String.t(), list) :: map
  def info(info_string, student_names \\ @students) do
    veggies = rows(info_string)
    pots = Enum.sort(student_names) |> Enum.zip(veggies) |> Map.new()
    Map.new(student_names, &{&1, {}}) |> Map.merge(pots)
  end

  defp rows(info_string) do
    [front, back] =
      String.split(info_string)
      |> Enum.map(&chunk_rows/1)

    Enum.zip(front, back)
    |> Enum.map(fn {[a, b], [c, d]} -> {a, b, c, d} end)
  end

  defp chunk_rows(row) do
    String.graphemes(row)
    |> Enum.map(&plant/1)
    |> Enum.chunk(2)
  end

  defp plant("C"), do: :clover
  defp plant("G"), do: :grass
  defp plant("R"), do: :radishes
  defp plant("V"), do: :violets
end
