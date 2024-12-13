defmodule TopSecret do
  def to_ast(string), do: Code.string_to_quoted!(string)

  def decode_secret_message_part({op, _meta, args} = ast, acc) when op in [:def, :defp] do
    {fn_name, fn_args} =
      case args do
        [{:when, _, [{fun, _, fn_args} | _]} | _] -> {fun, fn_args}
        [{fun, _, fn_args} | _] when is_list(fn_args) -> {fun, fn_args}
        [{fun, _, fn_args} | _] -> {fun, []}
      end

    secret = String.slice(to_string(fn_name), 0, length(fn_args))
    {ast, [secret | acc]}
  end

  def decode_secret_message_part(ast, acc), do: {ast, acc}

  def decode_secret_message(string) do
    ast = to_ast(string)
    {^ast, acc} = Macro.prewalk(ast, [], &decode_secret_message_part/2)
    acc |> Enum.reverse() |> Enum.join()
  end
end
