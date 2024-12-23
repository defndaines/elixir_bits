defmodule Username do
  @safe ~c"abcdefghijklmnopqrstuvwxyz_"

  def sanitize(str, acc \\ [])

  def sanitize([], acc), do: acc

  def sanitize([ch | rest], acc) do
    case ch do
      ?ü -> sanitize(rest, acc ++ ~c"ue")
      ?ö -> sanitize(rest, acc ++ ~c"oe")
      ?ä -> sanitize(rest, acc ++ ~c"ae")
      ?ß -> sanitize(rest, acc ++ ~c"ss")
      ch when ch in @safe -> sanitize(rest, acc ++ [ch])
      _ -> sanitize(rest, acc)
    end
  end
end
