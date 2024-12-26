defmodule Dominoes do
  @type domino :: {1..6, 1..6}

  @doc """
  chain?/1 takes a list of domino stones and returns boolean indicating if it's
  possible to make a full chain
  """
  @spec chain?(dominoes :: [domino]) :: boolean
  def chain?([]), do: true
  def chain?([{a, b}]), do: a == b

  def chain?([{a, b} | dominoes]) do
    Enum.any?(
      dominoes,
      fn
        {^b, c} = stone -> chain?([{a, c} | List.delete(dominoes, stone)])
        {c, ^b} = stone -> chain?([{a, c} | List.delete(dominoes, stone)])
        _ -> false
      end
    )
  end
end
