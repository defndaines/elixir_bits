defmodule Forth do
  @opaque word :: integer | String.t()
  @opaque actions :: %{name: String.t(), action: Function.t()}
  @opaque stack :: [word]
  @opaque evaluator :: {stack, actions}

  @non_words ~r/[^\s \x00\x01]+/

  @doc """
  Create a new evaluator.
  """
  @spec new() :: evaluator
  def new() do
    {
      [],
      %{
        "*" => &multiply/1,
        "+" => &add/1,
        "-" => &subtract/1,
        "/" => &divide/1,
        "DROP" => &drop/1,
        "DUP" => &duplicate/1,
        "OVER" => &over/1,
        "SWAP" => &swap/1
      }
    }
  end

  @doc """
  Evaluate an input string, updating the evaluator state.
  """
  @spec eval(evaluator, String.t()) :: evaluator
  def eval({stack, actions}, s) do
    do_eval(to_words(s), actions, stack)
  end

  @doc """
  Return the current stack as a string with the element on top of the stack
  being the rightmost element in the string.
  """
  @spec format_stack(evaluator) :: String.t()
  def format_stack({stack, _}) do
    stack
    |> Enum.reverse()
    |> Enum.join(" ")
  end

  ## Helper Functions

  @spec to_words(String.t()) :: stack
  defp to_words(string) do
    Regex.scan(@non_words, String.upcase(string))
    |> List.flatten()
    |> Enum.map(&int_or_cmd/1)
  end

  @spec int_or_cmd(String.t()) :: word
  defp int_or_cmd(word) do
    case Integer.parse(word) do
      {n, ""} -> n
      :error -> word
    end
  end

  @spec do_eval(stack, actions, [integer]) :: evaluator
  defp do_eval([], actions, stack), do: {stack, actions}

  defp do_eval([":" | rest], actions, stack) do
    {tail, new_actions} = define(rest, actions)
    do_eval(tail, new_actions, stack)
  end

  defp do_eval([i | rest], actions, stack) when is_integer(i) do
    do_eval(rest, actions, [i | stack])
  end

  defp do_eval([word | rest], actions, stack) do
    case Map.get(actions, word) do
      nil -> raise Forth.UnknownWord
      action -> do_eval(rest, actions, action.(stack))
    end
  end

  @spec define(stack, actions, String.t(), Function.t()) :: evaluator
  defp define(stack, actions, name \\ nil, action \\ &Function.identity/1)
  defp define([name | _], _, nil, _) when is_integer(name), do: raise(Forth.InvalidWord)

  defp define([";" | rest], actions, name, action) do
    {rest, Map.put(actions, name, action)}
  end

  defp define([name | rest], actions, nil, action) do
    define(rest, actions, name, action)
  end

  defp define([n | rest], actions, name, _) when is_integer(n) do
    define(rest, actions, name, fn stack -> [n | stack] end)
  end

  defp define([word | rest], actions, name, action) do
    case Map.get(actions, word) do
      nil -> :undefined
      existing -> define(rest, actions, name, fn stack -> existing.(action.(stack)) end)
    end
  end

  ## Default Stack Functions

  defp add([n, m | rest]), do: [m + n | rest]
  defp add(_), do: raise(Forth.StackUnderflow)

  defp divide([0 | _]), do: raise(Forth.DivisionByZero)
  defp divide([n, m | rest]), do: [div(m, n) | rest]
  defp divide(_), do: raise(Forth.StackUnderflow)

  defp drop([_ | rest]), do: rest
  defp drop(_), do: raise(Forth.StackUnderflow)

  defp duplicate([n | rest]), do: [n, n | rest]
  defp duplicate(_), do: raise(Forth.StackUnderflow)

  defp multiply([n, m | rest]), do: [m * n | rest]
  defp multiply(_), do: raise(Forth.StackUnderflow)

  defp over(stack = [_, m | _]), do: [m | stack]
  defp over(_), do: raise(Forth.StackUnderflow)

  defp subtract([n, m | rest]), do: [m - n | rest]
  defp subtract(_), do: raise(Forth.StackUnderflow)

  defp swap([n, m | rest]), do: [m, n | rest]
  defp swap(_), do: raise(Forth.StackUnderflow)

  ## Exceptions

  defmodule StackUnderflow do
    defexception []
    def message(_), do: "stack underflow"
  end

  defmodule InvalidWord do
    defexception word: nil
    def message(e), do: "invalid word: #{inspect(e.word)}"
  end

  defmodule UnknownWord do
    defexception word: nil
    def message(e), do: "unknown word: #{inspect(e.word)}"
  end

  defmodule DivisionByZero do
    defexception []
    def message(_), do: "division by zero"
  end
end
