defmodule ZebraPuzzle do
  @objects %{
    color: MapSet.new([:blue, :green, :ivory, :red, :yellow]),
    drink: MapSet.new([:water, :coffee, :tea, :orange_juice, :milk]),
    hobby: MapSet.new([:painting, :football, :reading, :dancing, :chess]),
    nationality: MapSet.new([:english, :japanese, :norwegian, :spanish, :ukrainian]),
    pet: MapSet.new([:dog, :snail, :horse, :fox, :zebra]),
    position: MapSet.new([1, 2, 3, 4, 5])
  }

  @doc """
  Determine who drinks the water
  """
  @spec drinks_water() :: atom
  def drinks_water(), do: get_in(puzzle(), [:truths, :drink, :nationality, :water])

  @doc """
  Determine who owns the zebra
  """
  @spec owns_zebra() :: atom
  def owns_zebra() do
    # knowledge = puzzle()
    # print(knowledge)
    get_in(puzzle(), [:truths, :pet, :nationality, :zebra])
  end

  defp build_knowledge(objects) do
    keys = Map.keys(objects)
    init = %{truths: %{}, falsehoods: %{}}

    for x <- keys, y <- keys, x != y, obj <- objects[x], reduce: init do
      acc ->
        acc
        |> put_in(Enum.map([:truths, x, y, obj], &Access.key(&1, %{})), nil)
        |> put_in(Enum.map([:falsehoods, x, y, obj], &Access.key(&1, %{})), MapSet.new())
    end
  end

  defp zebra_constraints(objects) do
    knowledge =
      objects
      # 1. There are five houses.
      |> build_knowledge()
      # 2. The Englishman lives in the red house.
      |> assert(objects, color: :red, nationality: :english)
      # 3. The Spaniard owns the dog.
      |> assert(objects, nationality: :spanish, pet: :dog)
      # 4. The person in the green house drinks coffee.
      |> assert(objects, color: :green, drink: :coffee)
      # 5. The Ukrainian drinks tea.
      |> assert(objects, drink: :tea, nationality: :ukrainian)
      # 6. The green house is immediately to the right of the ivory house.
      |> refute(color: :green, position: 1)
      |> refute(color: :ivory, position: 5)
      # 7. The snail owner likes to go dancing.
      |> assert(objects, hobby: :dancing, pet: :snail)
      # 8. The person in the yellow house is a painter.
      |> assert(objects, color: :yellow, hobby: :painting)
      # 9. The person in the middle house drinks milk.
      |> assert(objects, drink: :milk, position: 3)
      # 10. The Norwegian lives in the first house.
      |> assert(objects, nationality: :norwegian, position: 1)
      # 11. The person who enjoys reading lives in the house next to the person with the fox.
      |> refute(hobby: :reading, pet: :fox)
      # 12. The painter's house is next to the house with the horse.
      |> refute(hobby: :painting, pet: :horse)
      # 13. The person who plays football drinks orange juice.
      |> assert(objects, drink: :orange_juice, hobby: :football)
      # 14. The Japanese person plays chess.
      |> assert(objects, hobby: :chess, nationality: :japanese)
      # 15. The Norwegian lives next to the blue house.
      |> refute(color: :blue, nationality: :norwegian)

    next_to = fn a, b -> a == b + 1 or a + 1 == b end

    constraints = [
      # 6. The green house is immediately to the right of the ivory house.
      {[color: :green, color: :ivory], :position, fn a, b -> a == b + 1 end},
      # 11. The person who enjoys reading lives in the house next to the person with the fox.
      {[hobby: :reading, pet: :fox], :position, next_to},
      # 12. The painter's house is next to the house with the horse.
      {[hobby: :painting, pet: :horse], :position, next_to},
      # 15. The Norwegian lives next to the blue house.
      {[color: :blue, nationality: :norwegian], :position, next_to}
    ]

    {knowledge, constraints}
  end

  defp puzzle() do
    {knowledge, constraints} = zebra_constraints(@objects)

    propagate(knowledge, @objects, constraints)

    # This is necessary for first question
    # TODO: What happens next and what's missing to achieve second test?
  end

  defp assert(knowledge, objects, [{x, x_val}, {y, y_val}]) do
    not_x = MapSet.difference(objects[x], MapSet.new([x_val]))
    not_y = MapSet.difference(objects[y], MapSet.new([y_val]))

    knowledge =
      Enum.reduce(not_x, knowledge, fn z_val, acc ->
        update_in(acc, [:falsehoods, x, y, z_val], &MapSet.put(&1, y_val))
      end)

    knowledge =
      Enum.reduce(not_y, knowledge, fn z_val, acc ->
        update_in(acc, [:falsehoods, y, x, z_val], &MapSet.put(&1, x_val))
      end)

    knowledge
    |> put_or_raise([:truths, x, y, x_val], y_val)
    |> put_or_raise([:truths, y, x, y_val], x_val)
    |> put_in([:falsehoods, x, y, x_val], not_y)
    |> put_in([:falsehoods, y, x, y_val], not_x)
  end

  defp put_or_raise(knowledge, path, value) do
    old = get_in(knowledge, path)

    if old && old != value do
      raise("Attempting to replace #{old} with #{value} in #{inspect(path)}")
    else
      put_in(knowledge, path, value)
    end
  end

  defp refute(knowledge, [{x, x_val}, {y, y_val}]) do
    knowledge
    |> update_in([:falsehoods, x, y, x_val], &MapSet.put(&1, y_val))
    |> update_in([:falsehoods, y, x, y_val], &MapSet.put(&1, x_val))
  end

  defp propagate(knowledge, objects, constraints) do
    with_constraints =
      Enum.reduce(constraints, knowledge, fn constraint, acc ->
        apply_constraint(acc, objects, constraint)
      end)

    # if with_constraints != knowledge, do: IO.puts("CONSTRAINT CHANGE")

    updated =
      for {x, xs} <- objects, {y, _ys} <- objects, x != y, reduce: with_constraints do
        acc -> acc |> last_choice(objects, x, y) |> apply_truths(objects, xs, x, y)
      end

    # if updated != with_constraints, do: IO.puts("LAST CHOICE CHANGE")

    if updated == knowledge do
      knowledge
    else
      # IO.puts("もう一回！")
      propagate(updated, objects, constraints)
    end
  end

  defp last_choice(knowledge, objects, x, y) do
    Enum.reduce(objects[y], knowledge, fn y_val, acc ->
      falsehoods = get_in(acc, [:falsehoods, x, y])

      case Enum.reject(falsehoods, fn {_, vs} -> Enum.member?(vs, y_val) end) do
        [{x_val, _}] ->
          if get_in(acc, [:truths, x, y, x_val]) do
            acc
          else
            assert(acc, objects, [{x, x_val}, {y, y_val}])
          end

        _ ->
          acc
      end
    end)
  end

  defp apply_truths(knowledge, objects, xs, x, y) do
    Enum.reduce(xs, knowledge, fn x_val, acc ->
      if y_val = get_in(acc, [:truths, x, y, x_val]) do
        crosscheck = Map.keys(objects) -- [x, y]

        Enum.reduce(crosscheck, acc, fn z, acc ->
          Enum.reduce(get_in(acc, [:falsehoods, x, z, x_val]), acc, fn z_val, acc ->
            if get_in(acc, [:truths, y, z, y_val]) do
              acc
            else
              refute(acc, [{y, y_val}, {z, z_val}])
            end
          end)
        end)
      else
        acc
      end
    end)
  end

  defp apply_constraint(knowledge, objects, constraint) do
    {[{x, x_val}, {y, y_val}], z, fun} = constraint

    knowledge =
      if z_val = get_in(knowledge, [:truths, x, z, x_val]) do
        Enum.reduce(Enum.reject(objects[z], &fun.(z_val, &1)), knowledge, fn no, acc ->
          refute(acc, [{y, y_val}, {z, no}])
        end)
      else
        knowledge
      end

    knowledge =
      if z_val = get_in(knowledge, [:truths, y, z, y_val]) do
        Enum.reduce(Enum.reject(objects[z], &fun.(z_val, &1)), knowledge, fn no, acc ->
          refute(acc, [{x, x_val}, {z, no}])
        end)
      else
        knowledge
      end

    z_vals = get_in(knowledge, [:falsehoods, x, z, x_val])
    possibly_x = MapSet.difference(objects[z], z_vals)
    possibly_y = MapSet.difference(objects[z], get_in(knowledge, [:falsehoods, y, z, y_val]))

    ys =
      for x1 <- possibly_x, y1 <- possibly_y, fun.(x1, y1), uniq: true, into: MapSet.new() do
        y1
      end

    put_in(knowledge, [:falsehoods, y, z, y_val], MapSet.difference(objects[z], ys))
  end

  defp print(knowledge) do
    for [a, b] <- combinations(2, Map.keys(@objects)) do
      IO.puts("# #{a} x #{b} #")

      x_axis =
        @objects
        |> Map.get(a)
        |> Enum.map(&(&1 |> to_string() |> String.at(0)))
        |> Enum.sort()
        |> Enum.join(" ")

      y_axis =
        @objects |> Map.get(b) |> Enum.map(&(&1 |> to_string() |> String.at(0))) |> Enum.sort()

      IO.puts("  #{x_axis}")

      for {j, y} <- Enum.with_index(Enum.sort(@objects[b])) do
        line =
          Enum.sort(@objects[a])
          |> Enum.map(fn i ->
            if get_in(knowledge, [:truths, b, a, j]) == i do
              "O"
            else
              if i in get_in(knowledge, [:falsehoods, b, a, j]), do: "X", else: " "
            end
          end)
          |> Enum.join(" ")

        IO.puts("#{Enum.at(y_axis, y)} #{line}")
      end
    end
  end

  defp combinations(0, []), do: [[]]
  defp combinations(_, []), do: []

  defp combinations(length, [h | t]) do
    for(xs <- combinations(length - 1, t), do: [h | xs]) ++ combinations(length, t)
  end
end
