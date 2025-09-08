defmodule ZebraPuzzle do
  @objects %{
    color: [:blue, :green, :ivory, :red, :yellow],
    drink: [:coffee, :milk, :orange_juice, :tea, :water],
    hobby: [:chess, :dancing, :football, :painting, :reading],
    nationality: [:english, :japanese, :norwegian, :spanish, :ukrainian],
    pet: [:dog, :fox, :horse, :snail, :zebra],
    position: [1, 2, 3, 4, 5]
  }

  # @answer [
  #   [position: 1, color: :yellow, drink: :water, nationality: :norwegian, pet: :fox, hobby: :painting],
  #   [position: 2, color: :blue, drink: :tea, nationality: :ukrainian, pet: :horse, hobby: :reading],
  #   [position: 3, color: :red, drink: :milk, nationality: :english, pet: :snail, hobby: :dancing],
  #   [position: 4, color: :ivory, drink: :orange_juice, nationality: :spanish, pet: :dog, hobby: :football],
  #   [position: 5, color: :green, drink: :coffee, nationality: :japanese, pet: :zebra, hobby: :chess]
  # ]

  @doc """
  Determine who drinks the water
  """
  @spec drinks_water() :: atom
  def drinks_water(), do: answer(puzzle(), [:drink, :water, :nationality])

  @doc """
  Determine who owns the zebra
  """
  @spec owns_zebra() :: atom
  def owns_zebra(), do: answer(puzzle(), [:pet, :zebra, :nationality])

  def build_domains(objects) do
    keys = Map.keys(objects)

    for x <- keys, obj <- objects[x], y <- keys, x != y, reduce: %{} do
      acc -> put_in(acc, Enum.map([x, obj, y], &Access.key(&1, %{})), objects[y])
    end
  end

  def assert!(domains, objects, [{x, x_val}, {y, y_val}]) do
    if [y_val] == get_in(domains, [x, x_val, y]) do
      domains
    else
      domains =
        objects[y]
        |> List.delete(y_val)
        |> Enum.reduce(domains, &refute!(&2, [{y, &1}, {x, x_val}]))

      objects[x]
      |> List.delete(x_val)
      |> Enum.reduce(domains, &refute!(&2, [{x, &1}, {y, y_val}]))
    end
  end

  def refute!(domains, [{x, x_val}, {y, y_val}]) do
    domains
    |> update_in([x, x_val, y], &delete!(&1, y_val))
    |> update_in([y, y_val, x], &delete!(&1, x_val))
  end

  def propagate(domains, objects, constraints \\ []) do
    update = constraints |> Enum.reduce(domains, &apply_constraint/2) |> cross_pollinate(objects)
    if update == domains, do: domains, else: propagate(update, objects, constraints)
  end

  def print(domains, objects) do
    keys = Map.keys(objects)

    for [x, y] <- combinations(2, keys) do
      IO.puts("# #{x} x #{y} #")

      first_two = fn atom -> atom |> to_string() |> String.slice(0, 2) end
      x_axis = objects |> Map.get(x) |> Enum.map(first_two) |> Enum.join(" ")
      y_axis = objects |> Map.get(y) |> Enum.map(first_two)

      IO.puts("   #{x_axis}")

      for {b, i} <- Enum.with_index(objects[y]) do
        line =
          objects[x]
          |> Enum.map_join("  ", fn a ->
            ybxa = get_in(domains, [y, b, x])

            if [a] == ybxa do
              "O"
            else
              if a in ybxa, do: " ", else: "X"
            end
          end)

        IO.puts("#{Enum.at(y_axis, i)} #{line}")
      end
    end
  end

  defp answer(domains, path) do
    case get_in(domains, path) do
      [answer] -> answer
      oops -> String.to_atom("one_of_#{Enum.join(oops, "_")}")
    end
  end

  defp zebra_constraints(objects) do
    domains =
      objects
      # 1. There are five houses.
      |> build_domains()
      # 2. The Englishman lives in the red house.
      |> assert!(objects, color: :red, nationality: :english)
      # 3. The Spaniard owns the dog.
      |> assert!(objects, nationality: :spanish, pet: :dog)
      # 4. The person in the green house drinks coffee.
      |> assert!(objects, color: :green, drink: :coffee)
      # 5. The Ukrainian drinks tea.
      |> assert!(objects, drink: :tea, nationality: :ukrainian)
      # 6. The green house is immediately to the right of the ivory house.
      |> refute!(color: :green, position: 1)
      |> refute!(color: :ivory, position: 5)
      # 7. The snail owner likes to go dancing.
      |> assert!(objects, hobby: :dancing, pet: :snail)
      # 8. The person in the yellow house is a painter.
      |> assert!(objects, color: :yellow, hobby: :painting)
      # 9. The person in the middle house drinks milk.
      |> assert!(objects, drink: :milk, position: 3)
      # 10. The Norwegian lives in the first house.
      |> assert!(objects, nationality: :norwegian, position: 1)
      # 11. The person who enjoys reading lives in the house next to the person with the fox.
      |> refute!(hobby: :reading, pet: :fox)
      # 12. The painter's house is next to the house with the horse.
      |> refute!(hobby: :painting, pet: :horse)
      # 13. The person who plays football drinks orange juice.
      |> assert!(objects, drink: :orange_juice, hobby: :football)
      # 14. The Japanese person plays chess.
      |> assert!(objects, hobby: :chess, nationality: :japanese)
      # 15. The Norwegian lives next to the blue house. (see #10)
      |> assert!(objects, color: :blue, position: 2)

    next_to = fn a, b -> abs(a - b) == 1 end

    constraints = [
      # 6. The green house is immediately to the right of the ivory house.
      {[color: :green, color: :ivory], :position, fn a, b -> a == b + 1 end},
      # 11. The person who enjoys reading lives in the house next to the person with the fox.
      {[hobby: :reading, pet: :fox], :position, next_to},
      # 12. The painter's house is next to the house with the horse.
      {[hobby: :painting, pet: :horse], :position, next_to}
    ]

    {domains, constraints}
  end

  defp puzzle() do
    {domains, constraints} = zebra_constraints(@objects)
    domains = propagate(domains, @objects, constraints)
    guess(domains, @objects, constraints)
  end

  defp delete!(list, value) do
    if (updated = List.delete(list, value)) == [] do
      raise("empty! #{inspect({list, value})}")
    else
      updated
    end
  end

  defp cross_pollinate(domains, objects) do
    keys = Map.keys(objects)

    facts =
      for x <- keys,
          y <- keys,
          x != y,
          x_val <- objects[x],
          length(get_in(domains, [x, x_val, y])) == 1 do
        [{x, x_val}, {y, hd(get_in(domains, [x, x_val, y]))}]
      end

    # Anything that is true for a given x, must be false for all not_x

    domains =
      for [{x, x_val}, fact] <- facts, not_x <- List.delete(objects[x], x_val), reduce: domains do
        acc -> refute!(acc, [{x, not_x}, fact])
      end

    # Anything that cannot be true for x, must be false for related facts.
    for [{x, x_val}, {y, y_val}] <- facts,
        z <- Map.keys(objects) -- [x, y],
        not_x = objects[z] -- get_in(domains, [x, x_val, z]),
        not_y = objects[z] -- get_in(domains, [y, y_val, z]),
        z_val <- not_x -- not_y,
        reduce: domains do
      acc -> refute!(acc, [{y, y_val}, {z, z_val}])
    end
  end

  defp apply_constraint({[{x, x_val}, {y, y_val}], z, fun}, domains) do
    possible_xs = get_in(domains, [x, x_val, z])
    possible_ys = get_in(domains, [y, y_val, z])
    ys = for x1 <- possible_xs, y1 <- possible_ys, fun.(x1, y1), uniq: true, do: y1

    domains =
      for z_val <- possible_ys -- ys, reduce: domains do
        acc -> refute!(acc, [{y, y_val}, {z, z_val}])
      end

    xs = for x1 <- possible_xs, y1 <- possible_ys, fun.(x1, y1), uniq: true, do: x1

    for z_val <- possible_xs -- xs, reduce: domains do
      acc -> refute!(acc, [{x, x_val}, {z, z_val}])
    end
  end

  defp solved?(domains) do
    Enum.all?(
      for x <- Map.keys(domains),
          x_val <- Map.keys(domains[x]),
          {_, y_val} <- get_in(domains, [x, x_val]) do
        length(y_val) == 1
      end
    )
  end

  defp combinations(0, []), do: [[]]
  defp combinations(_, []), do: []

  defp combinations(length, [h | t]) do
    for(xs <- combinations(length - 1, t), do: [h | xs]) ++ combinations(length, t)
  end

  def guess(domains, objects, constraints \\ []) do
    if solved?(domains) do
      domains
    else
      open =
        for [x, y] <- combinations(2, Map.keys(objects)),
            x_val <- objects[x],
            y_vals = get_in(domains, [x, x_val, y]),
            length(y_vals) > 1,
            y_val <- y_vals do
          [{x, x_val}, {y, y_val}]
        end

      do_guess(open, domains, objects, constraints)
    end
  end

  defp do_guess([], _, _, _), do: raise("no solution from guessing")

  defp do_guess([fact | rest], domains, objects, constraints) do
    update = domains |> assert!(objects, fact) |> propagate(objects, constraints)
    if solved?(update), do: update, else: do_guess(rest, domains, objects, constraints)
  rescue
    _ -> do_guess(rest, domains, objects, constraints)
  end
end
