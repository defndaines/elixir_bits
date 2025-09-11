defmodule ConstraintSatisfaction do
  @moduledoc """
  Tools for solving Constraint Satisfaction Problems (CSPs).
  """

  @doc """
  Build the empty domain state information from the `objects` provided.

  Objects are represented by a map of variables to all possible answers. The following example
  shows that the possible weapons are a code book, a plague, and a squirrel.

      objects = %{
        suspect: [:rose, :obsidian, :applegreen],
        weapon: [:codebook, :plague, :squirrel],
        location: [:forest, :dungeon, :chamber],
        motive: [:revolution, :see_what_it_feels_like, :rob]
      }

  The domain state is represented by a nested map of keys and values for two variables, with the
  deepest key representing all remaining possible solutions for a key-value-key combination. Key
  pairs are double stored in the sense that `[x, x_val, y] => y_vals` and `[y, y_val, x] =>
  x_vals` are both represented in the state. The following example shows that for the forest
  location Rose, Obsidian, and Applegreen are all potential suspects.

      %{
        location: %{
          forest: %{
            suspect: [:rose, :obsidian, :applegreen],
            weapon: [:codebook, :plague, :squirrel],
            motive: [:revolution, :see_what_it_feels_like, :rob]
          }
        },
        suspect: %{
          rose: %{
            location: [:forest, :dungeon, :chamber],
            weapon: [:codebook, :plague, :squirrel],
            motive: [:revolution, :see_what_it_feels_like, :rob]
          },
        }
      }
  """
  def build_state(objects) do
    keys = Map.keys(objects)

    for x <- keys, obj <- objects[x], y <- keys, x != y, reduce: %{} do
      acc -> put_in(acc, Enum.map([x, obj, y], &Access.key(&1, %{})), objects[y])
    end
  end

  @doc """
  Assert a set of facts against the `state`.

  The `objects` must be provided to frame the fact, which are passed as a keyword list. The
  following examples asserts that suspect Applegreen was in the chamber location.

      assert(state, objects, location: :chamber, suspect: :applegreen)
  """
  def assert(state, objects, [{x, x_val}, {y, y_val}]) do
    if [y_val] == get_in(state, [x, x_val, y]) do
      state
    else
      state =
        objects[y]
        |> List.delete(y_val)
        |> Enum.reduce(state, &refute(&2, [{y, &1}, {x, x_val}]))

      objects[x]
      |> List.delete(x_val)
      |> Enum.reduce(state, &refute(&2, [{x, &1}, {y, y_val}]))
    end
  end

  @doc """
  Refute a set of facts (passed as a keyword list) against the `state`.

  The following example refutes that the suspect with the motivation to rob was in the forest
  location.

      refute(state, motive: :rob, location: :forest)
  """
  def refute(state, [{x, x_val}, {y, y_val}]) do
    state
    |> update_in([x, x_val, y], &List.delete(&1, y_val))
    |> update_in([y, y_val, x], &List.delete(&1, x_val))
  end

  @doc """
  Given the domain `state`, the `objects` that define the domains, and an optional set of
  `constraints`, propagate the know information across all state.

  When there are constraints, they are checked to eliminate any facts that are no longer possible.
  Then the state is checked across variables, such that all related facts are correlated. The
  propagation works recursively, such that if new solutions have been asserted, they are then
  propagated out. It is expected that if a completable set of assertions, refutations, and
  constraints have been provided, that the output will be a solved problem.
  """
  def propagate(state, objects, constraints \\ []) do
    update = constraints |> Enum.reduce(state, &apply_constraint/2) |> cross_pollinate(objects)
    if update == state, do: state, else: propagate(update, objects, constraints)
  end

  @doc """
  Evaluate `statements` where one is false that the rest are true, i.e., “two truths and a lie”.

  On the premise that the innocent always tell the truth, while the guilty always lie, evaluate
  the provided statements, flipping the assertion or refutation of one suspect to determine who is
  lying. Only one combination should result in a solved problem. When found, return a tuple of the
  guilty suspect along with the final domain state.
  """
  def evaluate_statements(state, objects, statements) do
    Enum.reduce_while(statements, state, fn {suspect, _, lie}, acc ->
      possibility =
        Enum.reduce(statements, state, fn
          {^suspect, :refute, _}, acc -> assert(acc, objects, lie)
          {^suspect, :assert, _}, acc -> refute(acc, lie)
          {_, :assert, fact}, acc -> assert(acc, objects, fact)
          {_, :refute, fact}, acc -> refute(acc, fact)
        end)
        |> propagate(objects)

      if solved?(possibility), do: {:halt, {suspect, possibility}}, else: {:cont, acc}
    end)
  end

  @doc """
  Evaluate two mutually exclusive `facts`, returning a `state` updated to account for whichever of
  the two "facts" is actually true.
  """
  def mutually_exclusive(state, objects, facts) do
    [fact_1, fact_2] = facts

    possibility = state |> assert(objects, fact_1) |> refute(fact_2) |> propagate(objects)

    if solved?(possibility) do
      possibility
    else
      state |> refute(fact_1) |> assert(objects, fact_2) |> propagate(objects)
    end
  end

  @doc """
  Given the `state` and a `path` of `[x, x_value, y]`, return the value for `y` if it is
  solved. Otherwise, return an atom indicating the possible solutions.
  """
  def answer(state, path) do
    case get_in(state, path) do
      [answer] -> answer
      oops -> String.to_atom("one_of_#{Enum.join(oops, "_")}")
    end
  end

  @doc """
  Print out a set of matrices showing the current `state` of the domains.

  Known values are marked with an "O". Impossible values are marked with an "X". Unknown values
  are left blank. The x and y axes values are shorted to two letters to preserve space. Only one
  matrix is output per pair of variables. So, only one of "suspect x location" and "location x
  suspect" will be shown. The following output shows that suspect Tuscany ("tu") was at the lake
  ("la") location.

      # location x suspect #
         sp la ru te
      tu X  O  X  X
      ve X  X  O  X
      au X  X  X  O
      ta O  X  X  X

  The following output shows a state where not all domains have been solved for. In this example,
  the drink coffee could be in either position 4 or 5.

      # position x drink #
         1  2  3  4  5
      co X  X  X
      mi X  X  O  X  X
      or X     X
      te X     X
      wa O  X  X  X  X
  """
  def print(state, objects) do
    keys = Map.keys(objects)

    for [x, y] <- combinations(2, keys) do
      IO.puts("# #{x} x #{y} #")

      first_two = fn
        number when is_number(number) -> "#{number} "
        atom when is_atom(atom) -> atom |> to_string() |> String.slice(0, 2)
      end

      x_axis = objects |> Map.get(x) |> Enum.map(first_two) |> Enum.join(" ")
      y_axis = objects |> Map.get(y) |> Enum.map(first_two)

      IO.puts("   #{x_axis}")

      for {b, i} <- Enum.with_index(objects[y]) do
        line =
          objects[x]
          |> Enum.map_join("  ", fn a ->
            ybxa = get_in(state, [y, b, x])

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

  @doc """
  Given the `state`, the base `objects`, and optionally any `constraints`, make guesses against
  the domain to come up with a solution.

  Some problems require some guessing. When this happens, work through the possible remaining
  solutions to see if a single fact can solve for the problem. This operates over all possible
  solutions, favoring shorter domains first, and short circuits once it finds a working solution.

  If no solution can be found, an error will be raised.
  """
  def guess(state, objects, constraints \\ []) do
    if solved?(state) do
      state
    else
      open =
        for [x, y] <- combinations(2, Map.keys(objects)),
            x_val <- objects[x],
            y_vals = get_in(state, [x, x_val, y]),
            length(y_vals) > 1,
            y_val <- y_vals do
          [{x, x_val}, {y, y_val}]
        end

      do_guess(open, state, objects, constraints)
    end
  end

  defp do_guess([], _, _, _), do: raise("no solution from guessing")

  defp do_guess([fact | rest], state, objects, constraints) do
    update = state |> assert(objects, fact) |> propagate(objects, constraints)
    if solved?(update), do: update, else: do_guess(rest, state, objects, constraints)
  end

  defp cross_pollinate(state, objects) do
    keys = Map.keys(objects)

    facts =
      for x <- keys,
          y <- keys,
          x != y,
          x_val <- objects[x],
          length(get_in(state, [x, x_val, y])) == 1 do
        [{x, x_val}, {y, hd(get_in(state, [x, x_val, y]))}]
      end

    # Anything that is true for a given x, must be false for all not_x

    state =
      for [{x, x_val}, fact] <- facts, not_x <- List.delete(objects[x], x_val), reduce: state do
        acc -> refute(acc, [{x, not_x}, fact])
      end

    # Anything that cannot be true for x, must be false for related facts.

    for [{x, x_val}, {y, y_val}] <- facts,
        z <- Map.keys(objects) -- [x, y],
        not_x = objects[z] -- get_in(state, [x, x_val, z]),
        not_y = objects[z] -- get_in(state, [y, y_val, z]),
        z_val <- not_x -- not_y,
        reduce: state do
      acc -> refute(acc, [{y, y_val}, {z, z_val}])
    end
  end

  defp apply_constraint({[{x, x_val}, {y, y_val}], z, fun}, state) do
    possible_xs = get_in(state, [x, x_val, z])
    possible_ys = get_in(state, [y, y_val, z])
    ys = for x1 <- possible_xs, y1 <- possible_ys, fun.(x1, y1), uniq: true, do: y1

    state =
      for z_val <- possible_ys -- ys, reduce: state do
        acc -> refute(acc, [{y, y_val}, {z, z_val}])
      end

    xs = for x1 <- possible_xs, y1 <- possible_ys, fun.(x1, y1), uniq: true, do: x1

    for z_val <- possible_xs -- xs, reduce: state do
      acc -> refute(acc, [{x, x_val}, {z, z_val}])
    end
  end

  @doc """
  Check if the `state` represents a solved problem.
  """
  def solved?(state) do
    Enum.all?(
      for x <- Map.keys(state),
          x_val <- Map.keys(state[x]),
          {_, y_val} <- get_in(state, [x, x_val]) do
        length(y_val) == 1
      end
    )
  end

  defp combinations(0, []), do: [[]]
  defp combinations(_, []), do: []

  defp combinations(length, [h | t]) do
    for(xs <- combinations(length - 1, t), do: [h | xs]) ++ combinations(length, t)
  end
end
