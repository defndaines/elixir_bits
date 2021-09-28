defmodule Username do
  @safe 'abcdefghijklmnopqrstuvwxyz_'

  def sanitize(str, acc \\ [])

  def sanitize([], acc), do: acc

  def sanitize([ch | rest], acc) do
    case ch do
      ?ü -> sanitize(rest, acc ++ 'ue')
      ?ö -> sanitize(rest, acc ++ 'oe')
      ?ä -> sanitize(rest, acc ++ 'ae')
      ?ß -> sanitize(rest, acc ++ 'ss')
      ch when ch in @safe -> sanitize(rest, acc ++ [ch])
      _ -> sanitize(rest, acc)
    end
  end
end
