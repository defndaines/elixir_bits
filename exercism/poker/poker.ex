defmodule Poker do
  @ranks ~w(1 2 3 4 5 6 7 8 9 10 J Q K A) |> Enum.with_index() |> Map.new()

  @doc """
  Given a list of poker hands, return a list containing the highest scoring hand.

  If two or more hands tie, return the list of tied hands in the order they were received.

  The basic rules and hand rankings for Poker can be found at:

  https://en.wikipedia.org/wiki/List_of_poker_hands

  For this exercise, we'll consider the game to be using no Jokers,
  so five-of-a-kind hands will not be tested. We will also consider
  the game to be using multiple decks, so it is possible for multiple
  players to have identical cards.

  Aces can be used in low (A 2 3 4 5) or high (10 J Q K A) straights, but do not count as
  a high card in the former case.

  For example, (A 2 3 4 5) will lose to (2 3 4 5 6).

  You can also assume all inputs will be valid, and do not need to perform error checking
  when parsing card values. All hands will be a list of 5 strings, containing a number
  (or letter) for the rank, followed by the suit.

  Ranks (lowest to highest): 2 3 4 5 6 7 8 9 10 J Q K A
  Suits (order doesn't matter): C D H S

  Example hand: ~w(4S 5H 4C 5D 4H) # Full house, 5s over 4s
  """
  @spec best_hand(list(list(String.t()))) :: list(list(String.t()))
  def best_hand(hands) do
    hands
    |> Enum.map(&parse_hand/1)
    |> Enum.sort_by(&score/1, :desc)
    |> Enum.reduce([], &winner/2)
    |> Enum.map(&to_hand/1)
  end

  defp parse_hand(hand) do
    hand
    |> Enum.map(fn card ->
      [^card, rank, suit] = Regex.run(~r/(.{1,2})([CDHS])/, card)
      {rank, suit}
    end)
    |> Enum.sort_by(&Map.get(@ranks, elem(&1, 0)), :desc)
    |> maybe_transpose()
  end

  defp maybe_transpose([{"A", suit} | [{"5", _}, {"4", _}, {"3", _}, {"2", _}] = hand]) do
    hand ++ [{"1", suit}]
  end

  defp maybe_transpose(hand), do: hand

  defp to_hand(hand), do: Enum.map(hand, fn {rank, suit} -> Enum.join([ace(rank), suit]) end)

  defp ace("1"), do: "A"
  defp ace(rank), do: rank

  defp winner(hand, []), do: [hand]

  defp winner(hand, [champ | _] = champs) do
    case {score(hand), score(champ)} do
      {same, same} -> face_off([hand | champs])
      {win, loss} when win > loss -> [hand]
      _ -> champs
    end
  end

  defp score([{rank, suit}, {_, suit}, {_, suit}, {_, suit}, {_, suit}] = hand) do
    if(straight?(hand), do: 900, else: 500) + @ranks[rank]
  end

  defp score([{triplet, _}, {triplet, _}, {triplet, _}, {pair, _}, {pair, _}]) do
    600 + @ranks[triplet] * 8 + @ranks[pair]
  end

  defp score([{pair, _}, {pair, _}, {triplet, _}, {triplet, _}, {triplet, _}]) do
    600 + @ranks[triplet] * 8 + @ranks[pair]
  end

  defp score([_, {rank, _}, {rank, _}, {rank, _}, {rank, _}]), do: 700 + @ranks[rank]
  defp score([{rank, _}, {rank, _}, {rank, _}, {rank, _}, _]), do: 700 + @ranks[rank]
  defp score([{rank, _}, {rank, _}, {rank, _}, _, _]), do: 300 + @ranks[rank]
  defp score([_, {rank, _}, {rank, _}, {rank, _}, _]), do: 300 + @ranks[rank]
  defp score([_, _, {rank, _}, {rank, _}, {rank, _}]), do: 300 + @ranks[rank]

  defp score(hand) do
    grouped = Enum.group_by(hand, &elem(&1, 0))

    cond do
      Enum.count(grouped) == 3 -> 200
      Enum.count(grouped) == 4 -> 100
      straight?(hand) -> 400
      true -> 0
    end
  end

  defp straight?([{rank, _} | _] = hand) do
    rank_val = @ranks[rank]
    Enum.map(hand, &@ranks[elem(&1, 0)]) == Range.to_list(rank_val..(rank_val - 4)//-1)
  end

  defp face_off(hands) do
    case high_card(hands) do
      :tie -> hands
      :left -> [hd(hands)]
      :right -> tl(hands)
    end
  end

  defp high_card([[], []]), do: :tie
  defp high_card([_]), do: :tie
  defp high_card([[{rank, _} | left], [{rank, _} | right]]), do: high_card([left, right])

  defp high_card([[{left, _} | _], [{right, _} | _]]) do
    if @ranks[left] > @ranks[right], do: :left, else: :right
  end
end
