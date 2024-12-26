defmodule CustomSet do
  @opaque t :: %__MODULE__{map: map}

  defstruct map: %{}

  @spec new(Enum.t()) :: t
  def new(enumerable), do: %__MODULE__{map: Enum.reduce(enumerable, %{}, &Map.put(&2, &1, nil))}

  @spec empty?(t) :: boolean
  def empty?(%{map: map}), do: map == %{}

  @spec contains?(t, any) :: boolean
  def contains?(%{map: map}, element), do: Map.has_key?(map, element)

  @spec subset?(t, t) :: boolean
  def subset?(%{map: set_1}, %{map: set_2}), do: Map.take(set_1, Map.keys(set_2)) == set_1

  @spec disjoint?(t, t) :: boolean
  def disjoint?(%{map: set_1}, %{map: set_2}), do: Map.drop(set_1, Map.keys(set_2)) == set_1

  @spec equal?(t, t) :: boolean
  def equal?(custom_set_1, custom_set_2), do: custom_set_1 == custom_set_2

  @spec add(t, any) :: t
  def add(%{map: set}, element), do: %__MODULE__{map: Map.put(set, element, nil)}

  @spec intersection(t, t) :: t
  def intersection(%{map: set_1}, %{map: set_2}) do
    %__MODULE__{map: Map.take(set_1, Map.keys(set_2))}
  end

  @spec difference(t, t) :: t
  def difference(%{map: set_1}, %{map: set_2}) do
    %__MODULE__{map: Map.drop(set_1, Map.keys(set_2))}
  end

  @spec union(t, t) :: t
  def union(%{map: set_1}, %{map: set_2}), do: %__MODULE__{map: Map.merge(set_1, set_2)}
end
