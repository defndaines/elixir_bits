defmodule ConstraintSatisfactionTest do
  use ExUnit.Case

  alias ConstraintSatisfaction, as: CSP

  describe "Zebra Puzzle" do
    setup :puzzle

    # answer = [
    #   [position: 1, color: :yellow, drink: :water, nationality: :norwegian, pet: :fox, hobby: :painting],
    #   [position: 2, color: :blue, drink: :tea, nationality: :ukrainian, pet: :horse, hobby: :reading],
    #   [position: 3, color: :red, drink: :milk, nationality: :english, pet: :snail, hobby: :dancing],
    #   [position: 4, color: :ivory, drink: :orange_juice, nationality: :spanish, pet: :dog, hobby: :football],
    #   [position: 5, color: :green, drink: :coffee, nationality: :japanese, pet: :zebra, hobby: :chess]
    # ]

    test "resident who drinks water", %{puzzle: puzzle} do
      # This can be solved without guessing.
      assert CSP.answer(puzzle, [:drink, :water, :nationality]) == :norwegian
    end

    test "resident who owns zebra", %{puzzle: puzzle} do
      # This requires guessing against the domain state in order to solve.
      assert CSP.answer(puzzle, [:pet, :zebra, :nationality]) == :japanese
    end

    defp puzzle(_) do
      objects = %{
        color: [:blue, :green, :ivory, :red, :yellow],
        drink: [:coffee, :milk, :orange_juice, :tea, :water],
        hobby: [:chess, :dancing, :football, :painting, :reading],
        nationality: [:english, :japanese, :norwegian, :spanish, :ukrainian],
        pet: [:dog, :fox, :horse, :snail, :zebra],
        position: [1, 2, 3, 4, 5]
      }

      state =
        objects
        # 1. There are five houses.
        |> CSP.build_state()
        # 2. The Englishman lives in the red house.
        |> CSP.assert(objects, color: :red, nationality: :english)
        # 3. The Spaniard owns the dog.
        |> CSP.assert(objects, nationality: :spanish, pet: :dog)
        # 4. The person in the green house drinks coffee.
        |> CSP.assert(objects, color: :green, drink: :coffee)
        # 5. The Ukrainian drinks tea.
        |> CSP.assert(objects, drink: :tea, nationality: :ukrainian)
        # 7. The snail owner likes to go dancing.
        |> CSP.assert(objects, hobby: :dancing, pet: :snail)
        # 8. The person in the yellow house is a painter.
        |> CSP.assert(objects, color: :yellow, hobby: :painting)
        # 9. The person in the middle house drinks milk.
        |> CSP.assert(objects, drink: :milk, position: 3)
        # 10. The Norwegian lives in the first house.
        |> CSP.assert(objects, nationality: :norwegian, position: 1)
        # 13. The person who plays football drinks orange juice.
        |> CSP.assert(objects, drink: :orange_juice, hobby: :football)
        # 14. The Japanese person plays chess.
        |> CSP.assert(objects, hobby: :chess, nationality: :japanese)
        # 15. The Norwegian lives next to the blue house. (see #10)
        |> CSP.assert(objects, color: :blue, position: 2)

      next_to = fn a, b -> abs(a - b) == 1 end

      constraints = [
        # 6. The green house is immediately to the right of the ivory house.
        {[color: :green, color: :ivory], :position, fn a, b -> a == b + 1 end},
        # 11. The person who enjoys reading lives in the house next to the person with the fox.
        {[hobby: :reading, pet: :fox], :position, next_to},
        # 12. The painter’s house is next to the house with the horse.
        {[hobby: :painting, pet: :horse], :position, next_to}
      ]

      state = CSP.propagate(state, objects, constraints)

      # The Zebra Puzzle is not directly solvable only from the asserted facts. It is necessary
      # to make guesses against remaining domain state to find a solution.
      [puzzle: CSP.guess(state, objects, constraints)]
    end
  end

  test "The Case of the Corpse under Hot Water (2025-09-08)" do
    murdle = %{
      suspect: [:tuscany, :vermillion, :aureolin, :tangerine],
      weapon: [:brick, :bow, :axe, :tea],
      location: [:spa, :lake, :ruins, :tent]
    }

    state =
      murdle
      |> CSP.build_state()
      # The suspect at the party lake had grey hair.
      |> CSP.assert(murdle, suspect: :tuscany, location: :lake)
      # The other suspect with the same height as Chancellor Tuscany was seen with a brick.
      |> CSP.assert(murdle, suspect: :tangerine, weapon: :brick)
      # A tea bag was found under a canvas flap.
      |> CSP.assert(murdle, weapon: :tea, location: :tent)
      # The Amazing Aureolin was in whatever-the-opposite-of-love-is with the person who brought a climbing axe.
      |> CSP.refute(suspect: :aureolin, weapon: :axe)
      # A metal-detector gave a positive reading by the ancient ruins.
      |> CSP.assert(murdle, weapon: :axe, location: :ruins)

    state = CSP.propagate(state, murdle)

    # The forest ranger’s body was found under hot water.
    assert %{suspect: [:tangerine], weapon: [:brick]} == get_in(state, [:location, :spa])
  end

  test "The Case of the Acorn (2025-09-09)" do
    murdle = %{
      suspect: [:rose, :obsidian, :applegreen],
      weapon: [:codebook, :plague, :squirrel],
      location: [:forest, :dungeon, :chamber],
      motive: [:revolution, :see_what_it_feels_like, :rob]
    }

    state =
      murdle
      |> CSP.build_state()
      # The suspect who shamelessly bragged about wanting to rob the victim was seen indoors.
      |> CSP.refute(motive: :rob, location: :forest)
      # Whoever was in a secret chamber was right-handed.
      |> CSP.assert(murdle, location: :chamber, suspect: :applegreen)
      # Either an ancient plague was in the Screaming Forest or Principal Applegreen was in the Screaming Forest. (But not both!)
      |> CSP.refute(weapon: :plague, suspect: :applegreen)
      # The suspect who wanted to see what it felt like to kill had a weapon made at least partially of paper.
      |> CSP.assert(murdle, motive: :see_what_it_feels_like, weapon: :codebook)
      # (Decoded) -> Grandmaster Rose was seen with a heavy codebook.
      |> CSP.assert(murdle, suspect: :rose, weapon: :codebook)

    # Either an ancient plague was in the Screaming Forest or Principal Applegreen was in the Screaming Forest. (But not both!)
    constraints = [
      {[weapon: :plague, suspect: :applegreen], :location,
       fn a, b -> a == :forest or b == :forest end}
    ]

    state = CSP.propagate(state, murdle, constraints)

    # A crazed squirrel was used to commit the murder.
    assert %{suspect: [:applegreen], location: [:chamber], motive: [:rob]} ==
             get_in(state, [:weapon, :squirrel])
  end
end
