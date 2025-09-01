defmodule GottaSnatchEmAll do
  @type card :: String.t()
  @type collection :: MapSet.t(card())

  @spec new_collection(card()) :: collection()
  def new_collection(card), do: MapSet.new([card])

  @spec add_card(card(), collection()) :: {boolean(), collection()}
  def add_card(card, collection) do
    if card in collection do
      {true, collection}
    else
      {false, MapSet.put(collection, card)}
    end
  end

  @spec trade_card(card(), card(), collection()) :: {boolean(), collection()}
  def trade_card(your_card, their_card, collection) do
    if your_card in collection do
      {their_card not in collection,
       collection |> MapSet.put(their_card) |> MapSet.delete(your_card)}
    else
      {false, MapSet.put(collection, their_card)}
    end
  end

  @spec remove_duplicates([card()]) :: [card()]
  def remove_duplicates(cards), do: cards |> MapSet.new() |> MapSet.to_list()

  @spec extra_cards(collection(), collection()) :: non_neg_integer()
  def extra_cards(your_collection, their_collection) do
    MapSet.difference(your_collection, their_collection) |> MapSet.size()
  end

  @spec boring_cards([collection()]) :: [card()]
  def boring_cards([]), do: []

  def boring_cards(collections) do
    collections |> Enum.reduce(&MapSet.intersection/2) |> MapSet.to_list()
  end

  @spec total_cards([collection()]) :: non_neg_integer()
  def total_cards([]), do: 0
  def total_cards(collections), do: collections |> Enum.reduce(&MapSet.union/2) |> MapSet.size()

  @spec split_shiny_cards(collection()) :: {[card()], [card()]}
  def split_shiny_cards(collection) do
    {shiny, matte} = MapSet.split_with(collection, &String.starts_with?(&1, "Shiny"))
    {MapSet.to_list(shiny), MapSet.to_list(matte)}
  end
end
