defmodule BracketPush do
  @doc """
  Checks that all the brackets and braces in the string are matched correctly, and nested correctly
  """
  @spec check_brackets(String.t) :: boolean
  def check_brackets(str) do
    Enum.empty?(Enum.reduce(String.graphemes(str), [], &do_check/2))
  end

  @brackets ["[", "{", "(", "]", "}", ")"]

  defp do_check(ch, []) do
    case Enum.find_index(@brackets, &(&1 == ch)) do
      nil -> []
      _ -> [ch]
    end
  end
  defp do_check(ch, [b | tail] = list) do
    case { Enum.find_index(@brackets, &(&1 == b)), Enum.find_index(@brackets, &(&1 == ch)) } do
      { open, close } when open == (close - 3) -> tail
      { _, nil } -> list
      { _, _ } -> [ch | list]
    end
  end
end
