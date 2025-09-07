defmodule ZebraPuzzle do
  @objects %{
    color: [:blue, :green, :ivory, :red, :yellow],
    drink: [:water, :coffee, :tea, :orange_juice, :milk],
    hobby: [:painting, :football, :reading, :dancing, :chess],
    nationality: [:english, :japanese, :norwegian, :spanish, :ukrainian],
    pet: [:dog, :snail, :horse, :fox, :zebra],
    position: [1, 2, 3, 4, 5]
  }

  # ANSWER
  # [position: 1, color: :yellow, drink: :water, nationality: :norwegian, pet: (:fox | :zebra), hobby: :painting]
  # [position: 2, color: :blue, drink: (:orange_juice | :tea), nationality: (:japanese | :ukrainian), pet: :horse, hobby: ?]
  # [position: 3, color: :red, drink: :milk, nationality: ?, pet: ?, hobby: ?]
  # [position: 4, color: :ivory, drink: ?, nationality: ?, pet: ?, hobby: ?]
  # [position: 5, color: :green, drink: ?, nationality: ?, pet: ?, hobby: ?]

  @doc """
  Determine who drinks the water
  """
  @spec drinks_water() :: atom
  def drinks_water(), do: puzzle() |> get_in([:drink, :water, :nationality]) |> Enum.at(0)

  @doc """
  Determine who owns the zebra
  """
  @spec owns_zebra() :: atom
  def owns_zebra() do
    knowledge = puzzle()
    # print(knowledge)

    case get_in(knowledge, [:pet, :zebra, :nationality]) do
      [answer] -> answer
      oops -> oops
    end

    # puzzle() |> get_in([:pet, :zebra, :nationality]) |> Enum.at(0)
  end

  defp build_knowledge(objects) do
    keys = Map.keys(objects)

    for x <- keys, obj <- objects[x], y <- keys, x != y, reduce: %{} do
      acc -> put_in(acc, Enum.map([x, obj, y], &Access.key(&1, %{})), objects[y])
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
      |> refute!(objects, color: :green, position: 1)
      |> refute!(objects, color: :ivory, position: 5)
      # 7. The snail owner likes to go dancing.
      |> assert(objects, hobby: :dancing, pet: :snail)
      # 8. The person in the yellow house is a painter.
      |> assert(objects, color: :yellow, hobby: :painting)
      # 9. The person in the middle house drinks milk.
      |> assert(objects, drink: :milk, position: 3)
      # 10. The Norwegian lives in the first house.
      |> assert(objects, nationality: :norwegian, position: 1)
      # 11. The person who enjoys reading lives in the house next to the person with the fox.
      |> refute!(objects, hobby: :reading, pet: :fox)
      # 12. The painter's house is next to the house with the horse.
      |> refute!(objects, hobby: :painting, pet: :horse)
      # 13. The person who plays football drinks orange juice.
      |> assert(objects, drink: :orange_juice, hobby: :football)
      # 14. The Japanese person plays chess.
      |> assert(objects, hobby: :chess, nationality: :japanese)
      # 15. The Norwegian lives next to the blue house.
      |> refute!(objects, color: :blue, nationality: :norwegian)

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

    # TODO: What happens next and what's missing to achieve second test?
    #   Might have to take a guessing strategy next, proposing a new fact and see if it fails.
    #   If guessing, best to choose from something that only has two choices left and has a
    #   constraint.
  end

  defp assert(knowledge, objects, [{x, x_val}, {y, y_val}]) do
    not_x = List.delete(objects[x], x_val)
    not_y = List.delete(objects[y], y_val)

    knowledge =
      Enum.reduce(not_x, knowledge, fn z_val, acc ->
        refute!(acc, objects, [{x, z_val}, {y, y_val}])
      end)

    knowledge =
      Enum.reduce(not_y, knowledge, fn z_val, acc ->
        refute!(acc, objects, [{y, z_val}, {x, x_val}])
      end)

    knowledge =
      for y_val <- not_y, reduce: knowledge do
        acc -> refute!(acc, objects, [{x, x_val}, {y, y_val}])
      end

    for x_val <- not_x, reduce: knowledge do
      acc -> refute!(acc, objects, [{x, x_val}, {y, y_val}])
    end
  end

  defp propagate(knowledge, objects, constraints) do
    acc =
      Enum.reduce(constraints, knowledge, fn constraint, acc ->
        apply_constraint(acc, objects, constraint)
      end)

    acc = cross_pollinate(acc, objects)

    if acc == knowledge, do: knowledge, else: propagate(acc, objects, constraints)
  end

  defp delete!(list, value) do
    if (u = List.delete(list, value)) == [] do
      raise("empty! #{inspect({list, value})}")
    else
      u
    end
  end

  defp refute!(acc, objects, [{x, x_val}, {y, y_val}]) do
    answered? = length(get_in(acc, [x, x_val, y])) == 1

    acc =
      acc
      |> update_in([x, x_val, y], &delete!(&1, y_val))
      |> update_in([y, y_val, x], &delete!(&1, x_val))

    if not answered? do
      case get_in(acc, [x, x_val, y]) do
        [answer] -> assert(acc, objects, [{x, x_val}, {y, answer}])
        _ -> acc
      end
    else
      acc
    end
  end

  # When two facts are mutually exclusive, remove them from the domain.
  # {x1, y1} and {x2, z2}, so {y1, z2} is not possible.
  defp cross_pollinate(knowledge, objects) do
    keys = Map.keys(objects)

    knowledge =
      for x <- keys, y <- keys, x != y, x_val <- objects[x], reduce: knowledge do
        acc ->
          case get_in(acc, [x, x_val, y]) do
            [y_val] ->
              acc =
                if [x_val] == get_in(acc, [y, y_val, x]) do
                  acc
                else
                  assert(acc, objects, [{y, y_val}, {x, x_val}])
                end

              for z <- keys -- [x, y], not_x <- List.delete(objects[x], x_val), reduce: acc do
                acc ->
                  case get_in(acc, [x, not_x, z]) do
                    [z_val] -> refute!(acc, objects, [{y, y_val}, {z, z_val}])
                    _ -> acc
                  end
              end

            _ ->
              acc
          end
      end

    for y <- keys, x <- keys, y != x, y_val <- objects[y], reduce: knowledge do
      acc ->
        case get_in(acc, [y, y_val, x]) do
          [x_val] ->
            acc =
              if [y_val] == get_in(acc, [x, x_val, y]) do
                acc
              else
                assert(acc, objects, [{x, x_val}, {y, y_val}])
              end

            for z <- keys -- [y, x], not_y <- List.delete(objects[y], y_val), reduce: acc do
              acc ->
                case get_in(acc, [y, not_y, z]) do
                  [z_val] -> refute!(acc, objects, [{x, x_val}, {z, z_val}])
                  _ -> acc
                end
            end

          _ ->
            acc
        end
    end
  end

  defp apply_constraint(knowledge, objects, {[{x, x_val}, {y, y_val}], z, fun}) do
    knowledge =
      case get_in(knowledge, [x, x_val, z]) do
        [z_val] ->
          Enum.reduce(Enum.reject(objects[z], &fun.(z_val, &1)), knowledge, fn nope, acc ->
            refute!(acc, objects, [{y, y_val}, {z, nope}])
          end)

        _ ->
          knowledge
      end

    knowledge =
      case get_in(knowledge, [y, y_val, z]) do
        [z_val] ->
          Enum.reduce(Enum.reject(objects[z], &fun.(z_val, &1)), knowledge, fn nope, acc ->
            refute!(acc, objects, [{x, x_val}, {z, nope}])
          end)

        _ ->
          knowledge
      end

    possible_xs = get_in(knowledge, [x, x_val, z])
    possible_ys = get_in(knowledge, [y, y_val, z])
    ys = for x1 <- possible_xs, y1 <- possible_ys, fun.(x1, y1), uniq: true, do: y1

    for z_val <- objects[z] -- ys, reduce: knowledge do
      acc -> refute!(acc, objects, [{y, y_val}, {z, z_val}])
    end
  end

  defp print(knowledge) do
    # keys = Map.keys(@objects)
    keys = [:position, :color, :drink, :nationality, :pet, :hobby]

    for [a, b] <- combinations(2, keys) do
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
          @objects[a]
          |> Enum.sort()
          |> Enum.map_join(" ", fn i ->
            bjai = get_in(knowledge, [b, j, a])

            if [i] == bjai do
              "O"
            else
              if i in bjai, do: " ", else: "X"
            end
          end)

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
