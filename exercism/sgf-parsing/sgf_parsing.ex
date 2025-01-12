defmodule SgfParsing do
  defmodule Sgf do
    defstruct properties: %{}, children: []
  end

  @type sgf :: %Sgf{properties: map, children: [sgf]}

  @doc """
  Parse a string into a Smart Game Format tree
  """
  @spec parse(encoded :: String.t()) :: {:ok, sgf} | {:error, String.t()}
  def parse(""), do: {:error, "tree missing"}
  def parse(";"), do: {:error, "tree missing"}
  def parse("()"), do: {:error, "tree with no nodes"}

  def parse(encoded) do
    case encoded |> String.to_charlist() |> do_parse() do
      %Sgf{} = sgf -> {:ok, %{sgf | children: Enum.reverse(sgf.children)}}
      error -> error
    end
  end

  defp do_parse(encoded, key \\ [], acc \\ nil)

  defp do_parse([], _, acc), do: acc
  defp do_parse([?( | encoded], key, acc), do: do_parse(encoded, key, acc)
  defp do_parse([?) | encoded], key, acc), do: do_parse(encoded, key, acc)

  defp do_parse([?; | encoded], _, acc) do
    case Enum.split_while(encoded, &(&1 != ?[)) do
      {[?)], _} ->
        %Sgf{}

      {_, []} ->
        {:error, "properties without delimiter"}

      {key, rest} ->
        if Enum.all?(key, &(&1 in ?A..?Z)) do
          sgf = if acc, do: %{acc | children: [%Sgf{} | acc.children]}, else: %Sgf{}
          do_parse(rest, to_string(key), sgf)
        else
          {:error, "property must be in uppercase"}
        end
    end
  end

  defp do_parse([?[ | encoded], key, acc) do
    {value, rest} = split_bracket(encoded)
    do_parse(rest, key, update_state(acc, key, value))
  end

  defp do_parse([ch | encoded], _, acc) do
    {key, rest} = Enum.split_while(encoded, &(&1 != ?[))

    cond do
      Enum.all?(key, &(&1 in ?A..?Z)) -> do_parse(rest, to_string([ch | key]), acc)
      true -> {:error, "property must be in uppercase"}
    end
  end

  defp split_bracket(encoded) do
    {value, rest} = Enum.split_while(encoded, &(&1 != ?]))

    cond do
      Enum.take(value, -2) == [?\\, ?\\] ->
        {Enum.drop(value, -1), tl(rest)}

      List.last(value) == ?\\ ->
        {more, tail} = rest |> tl() |> split_bracket()
        {[Enum.drop(value, -1) | [?] | more]], tail}

      true ->
        {value, tl(rest)}
    end
  end

  defp update_state(state, key, value) do
    value = normalize_value(value)

    case state.children do
      [head | tail] ->
        child = %{head | properties: Map.update(head.properties, key, [value], &(&1 ++ [value]))}
        %{state | children: [child | tail]}

      [] ->
        %{state | properties: Map.update(state.properties, key, [value], &(&1 ++ [value]))}
    end
  end

  defp normalize_value(value) do
    value
    |> to_string()
    |> String.replace("\\\n", "")
    |> String.replace(~r/\\(.)/, "\\1")
    |> String.replace(~r/\t/, " ")
  end
end
