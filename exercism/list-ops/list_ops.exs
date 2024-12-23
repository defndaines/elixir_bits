defmodule ListOps do
  # Please don't use any external modules (especially List) in your
  # implementation. The point of this exercise is to create these basic functions
  # yourself.
  #
  # Note that `++` is a function from an external module (Kernel, which is
  # automatically imported) and so shouldn't be used either.

  @spec count(list) :: non_neg_integer
  def count([]), do: 0

  def count(l) do
    reduce(l, 0, fn _, acc -> acc + 1 end)
  end

  @spec reverse(list) :: list
  def reverse(l), do: reverse(l, [])
  def reverse([], acc), do: acc

  def reverse([head | tail], acc) do
    reverse(tail, [head | acc])
  end

  @spec map(list, (any -> any)) :: list
  def map(l, f) do
    reduce(l, [], &[f.(&1) | &2]) |> reverse
  end

  @spec filter(list, (any -> as_boolean(term))) :: list
  def filter(l, f) do
    reduce(l, [], fn elem, acc ->
      if f.(elem) do
        [elem | acc]
      else
        acc
      end
    end)
    |> reverse
  end

  @type acc :: any
  @spec reduce(list, acc, (any, acc -> acc)) :: acc
  def reduce([], acc, _), do: acc

  def reduce([head | tail], acc, f) do
    reduce(tail, f.(head, acc), f)
  end

  @spec append(list, list) :: list
  def append(a, b) do
    reduce(reverse(a), b, fn elem, acc -> [elem | acc] end)
  end

  @spec concat([[any]]) :: [any]
  def concat([]), do: []
  def concat([[]]), do: []

  def concat([head | tail]) do
    append(head, concat(tail))
  end
end
