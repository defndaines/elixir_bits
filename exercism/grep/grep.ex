defmodule Grep do
  @spec grep(String.t(), [String.t()], [String.t()]) :: String.t()
  def grep(pattern, flags, files) do
    number? = Enum.member?(flags, "-n")
    path_only? = Enum.member?(flags, "-l")
    insensitive? = Enum.member?(flags, "-i")
    invert? = Enum.member?(flags, "-v")
    entire? = Enum.member?(flags, "-x")
    multiple? = length(files) > 1 and not path_only?

    pattern = if insensitive?, do: String.downcase(pattern), else: pattern

    files
    |> Enum.map(&{&1, lines(&1)})
    |> Enum.reduce([], fn {path, lines}, acc ->
      lines
      |> Enum.with_index(fn line, n ->
        to_check = if insensitive?, do: String.downcase(line), else: line
        found? = if entire?, do: to_check == pattern, else: String.contains?(to_check, pattern)
        found? = if invert?, do: not found?, else: found?
        {found?, n + 1, line}
      end)
      |> Enum.reduce(acc, fn
        {false, _, _}, acc ->
          acc

        {_, _, ""}, acc ->
          acc

        {true, n, line}, acc ->
          formatted =
            cond do
              path_only? -> path
              number? -> "#{n}:#{line}"
              true -> line
            end

          formatted = if multiple?, do: "#{path}:#{formatted}", else: formatted

          acc ++ [formatted]
      end)
    end)
    |> Enum.uniq()
    |> Enum.join("\n")
    |> newline()
  end

  defp lines(path), do: path |> File.read!() |> String.split("\n")

  defp newline(""), do: ""
  defp newline(line), do: String.trim(line) <> "\n"
end
