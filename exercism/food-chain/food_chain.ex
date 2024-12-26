defmodule FoodChain do
  @animals ~w(horse cow goat dog cat bird spider fly)

  @doc """
  Generate consecutive verses of the song 'I Know an Old Lady Who Swallowed a Fly'.
  """
  @spec recite(start :: integer, stop :: integer) :: String.t()
  def recite(start, stop) do
    start..stop
    |> Enum.map(&(Enum.drop(@animals, 8 - &1) |> verse() |> Enum.join("\n")))
    |> Enum.join("\n\n")
    |> Kernel.<>("\n")
  end

  defp verse(["fly"]), do: [swallow("fly") | outro()]
  defp verse(["horse" | _]), do: [swallow("horse"), "She's dead, of course!"]

  defp verse([animal | _] = beasts) do
    [swallow(animal), intro(animal) | descend(beasts)] ++ outro()
  end

  defp swallow(animal), do: "I know an old lady who swallowed a #{animal}."

  defp intro("spider"), do: "It wriggled and jiggled and tickled inside her."
  defp intro("bird"), do: "How absurd to swallow a bird!"
  defp intro("cat"), do: "Imagine that, to swallow a cat!"
  defp intro("dog"), do: "What a hog, to swallow a dog!"
  defp intro("goat"), do: "Just opened her throat and swallowed a goat!"
  defp intro("cow"), do: "I don't know how she swallowed a cow!"

  defp descend([_]), do: []

  defp descend(["bird" | beasts]) do
    [
      "She swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her."
      | descend(beasts)
    ]
  end

  defp descend([animal | beasts]) do
    ["She swallowed the #{animal} to catch the #{hd(beasts)}." | descend(beasts)]
  end

  defp outro(), do: ["I don't know why she swallowed the fly. Perhaps she'll die."]
end
