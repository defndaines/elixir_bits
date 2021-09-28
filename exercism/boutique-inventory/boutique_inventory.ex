defmodule BoutiqueInventory do
  def sort_by_price(inventory) do
    Enum.sort_by(inventory, & &1.price)
  end

  def with_missing_price(inventory) do
    Enum.reject(inventory, & &1.price)
  end

  def increase_quantity(%{quantity_by_size: data} = item, count) do
    %{
      item
      | quantity_by_size:
          data
          |> Stream.map(fn {k, v} -> {k, v + count} end)
          |> Enum.into(%{})
    }
  end

  def total_quantity(item) do
    item.quantity_by_size
    |> Map.values()
    |> Enum.sum()
  end
end
