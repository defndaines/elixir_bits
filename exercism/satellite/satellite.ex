defmodule Satellite do
  @typedoc """
  A tree, which can be empty, or made from a left branch, a node and a right branch
  """
  @type tree :: {} | {tree, any, tree}

  @doc """
  Build a tree from the elements given in a pre-order and in-order style
  """
  @spec build_tree(preorder :: [any], inorder :: [any]) :: {:ok, tree} | {:error, String.t()}
  def build_tree(preorder, inorder) do
    cond do
      length(preorder) != length(inorder) ->
        {:error, "traversals must have the same length"}

      Enum.sort(preorder) != Enum.sort(inorder) ->
        {:error, "traversals must have the same elements"}

      length(Enum.uniq(preorder)) != length(preorder) ->
        {:error, "traversals must contain unique items"}

      true ->
        {:ok, build(preorder, inorder)}
    end
  end

  defp build([], []), do: {}

  defp build([e | preorder], inorder) do
    {left_in, [^e | right_in]} = Enum.split_while(inorder, &(&1 != e))
    {left_pre, right_pre} = Enum.split_with(preorder, &(&1 in left_in))
    {build(left_pre, left_in), e, build(right_pre, right_in)}
  end
end
