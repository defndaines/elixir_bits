defmodule LanguageList do
  def new(), do: []

  def add(list, language), do: [language | list]

  def remove([_ | rest]), do: rest

  def first([head | _]), do: head

  def count(list, acc \\ 0)

  def count([], acc), do: acc
  def count([_ | rest], acc), do: count(rest, acc + 1)

  def exciting_list?([]), do: false
  def exciting_list?(["Elixir" | _]), do: true
  def exciting_list?([_ | rest]), do: exciting_list?(rest)
end
