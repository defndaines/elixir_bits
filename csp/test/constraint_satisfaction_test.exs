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

  test "The Unfortunate-Demise-of-the-Art-Collector Murder (2025-09-10)" do
    murdle = %{
      suspect: [:viscount_eminence, :admiral_navy, :signor_emerald],
      weapon: [:rare_vase, :murdle_vol_1, :glass_of_poisoned_wine],
      location: [:bathroom, :entry_hall, :art_studio]
    }

    state =
      murdle
      |> CSP.build_state()
      # A paper-detector gave a positive reading on Signor Emerald.
      |> CSP.assert(murdle, suspect: :signor_emerald, weapon: :murdle_vol_1)
      # The tallest suspect was in whatever-the-opposite-of-love-is with the person who brought a rare vase.
      |> CSP.refute(suspect: :admiral_navy, weapon: :rare_vase)
      |> CSP.propagate(murdle)

    statements = [
      # Viscount Eminence: A glass of poisoned wine was not in the entry hall.
      {:viscount_eminence, :refute, weapon: :glass_of_poisoned_wine, location: :entry_hall},
      # Admiral Navy: Viscount Eminence was in the entry hall.
      {:admiral_navy, :assert, suspect: :viscount_eminence, location: :entry_hall},
      # Signor Emerald: Viscount Eminence was not in an art studio.
      {:signor_emerald, :refute, suspect: :viscount_eminence, location: :art_studio}
    ]

    {suspect, state} = CSP.evaluate_statements(state, murdle, statements)

    assert :admiral_navy == suspect

    assert %{location: [:art_studio], weapon: [:glass_of_poisoned_wine]} ==
             get_in(state, [:suspect, suspect])
  end

  test "Deductive Logico and the Case of the Virgo with the Leather Luggage (2025-09-11)" do
    murdle = %{
      suspect: [:babyface_blue, :lord_lavender, :captain_slate, :sir_rulean],
      location: [:sleeping_car, :observation_deck, :caboose, :dining_car],
      weapon: [
        :brick_of_coal,
        :rolled_up_newspaper_with_a_crowbar_inside,
        :leather_luggage,
        :bottle_of_wine
      ]
    }

    state =
      murdle
      |> CSP.build_state()
      # Whoever was in the dining car had blue eyes.
      |> CSP.refute(location: :dining_car, suspect: [:lord_lavender, :captain_slate])
      # The second shortest suspect did not bring a bottle of wine.
      |> CSP.refute(suspect: :sir_rulean, weapon: :bottle_of_wine)
      # This fingerprint was found on a rolled-up newspaper with a crowbar inside.
      |> CSP.assert(murdle,
        suspect: :babyface_blue,
        weapon: :rolled_up_newspaper_with_a_crowbar_inside
      )
      # Leather luggage was brought by a member of The Order of the Wand, and only Virgos are allowed to join the The Order of the Wand.
      |> CSP.assert(murdle, suspect: :lord_lavender, weapon: :leather_luggage)
      # Traces of a weapon made of metal were found in the sleeping car.
      |> CSP.refute(location: :sleeping_car, weapon: [:brick_of_coal, :bottle_of_wine])
      # Either Sir Rulean was in the back of the train or Lord Lavender brought a bottle of wine. (But not both!)
      |> CSP.mutually_exclusive(murdle, [
        [suspect: :sir_rulean, location: :caboose],
        [suspect: :lord_lavender, weapon: :bottle_of_wine]
      ])

    # The murder took place by an outdoor railing.
    assert %{suspect: [:captain_slate], weapon: [:bottle_of_wine]} ==
             get_in(state, [:location, :observation_deck])
  end

  test "The Mystery of the Body beneath a Stained Glass Window (2025-09-12)" do
    murdle = %{
      suspect: [:judge_pine, :uncle_midnight, :father_mango, :baron_maroon, :mayor_honey],
      location: [:chapel, :town_square, :manor_house, :quaint_garden, :new_development],
      weapon: [:bottle_of_cyanide, :yarn, :pair_of_gardening_shears, :human_skull, :chessboard]
    }

    state =
      murdle
      |> CSP.build_state()
      # Analysts discovered traces of a weapon made of metal on the clothing of Father Mango.
      |> CSP.assert(murdle, weapon: :pair_of_gardening_shears, suspect: :father_mango)
      # The second shortest suspect was seen hanging around beneath an enormous painting.
      |> CSP.assert(murdle, suspect: :uncle_midnight, location: :manor_house)
      # A pair of gardening shears was not in the quaint garden.
      |> CSP.refute(weapon: :pair_of_gardening_shears, location: :quaint_garden)
      # Uncle Midnight was childhood friends with the person who brought a human skull.
      |> CSP.refute(suspect: :uncle_midnight, weapon: :human_skull)
      # The remains of a human head was seen indoors.
      |> CSP.refute(
        weapon: :human_skull,
        location: [:town_square, :quaint_garden, :new_development]
      )
      # The suspect at the new development had black hair.
      |> CSP.assert(murdle, suspect: :judge_pine, location: :new_development)
      # This fingerprint was found on a bottle of cyanide.
      |> CSP.assert(murdle, suspect: :judge_pine, weapon: :bottle_of_cyanide)
      # Either Mayor Honey brought yarn or Judge Pine was in the town square. (But not both!)
      |> CSP.mutually_exclusive(murdle, [
        [suspect: :mayor_honey, weapon: :yarn],
        [suspect: :judge_pine, location: :town_square]
      ])

    # The body was found in the chapel.
    assert %{suspect: [:baron_maroon], weapon: [:human_skull]} ==
             get_in(state, [:location, :chapel])
  end

  test "The Case of the Unfortunate Demise of the One of the Locals (2025-09-13)" do
    murdle = %{
      suspect: [:earl_grey, :dr_crimson, :secretary_celadon, :general_coffee],
      weapon: [:snowglobe, :climbing_rope, :murdle_vol_1, :stone_dagger],
      location: [:trailhead, :gift_shop, :five_star_hotel, :boutique_hotel],
      motive: [:win_an_argument, :escape_blackmail, :rage_with_jealousy, :silence_a_witness]
    }

    state =
      murdle
      |> CSP.build_state()
      # Dr Crimson wanted to rage with jealousy.
      |> CSP.assert(murdle, suspect: :dr_crimson, motive: :rage_with_jealousy)
      # Secretary Celadon was seen outdoors.
      |> CSP.assert(murdle, suspect: :secretary_celadon, location: :trailhead)
      # The person with a stone dagger wanted to silence a witness.
      |> CSP.assert(murdle, weapon: :stone_dagger, motive: :silence_a_witness)
      # This fingerprint was found on Murdle: Volume 1.
      |> CSP.assert(murdle, suspect: :general_coffee, weapon: :murdle_vol_1)
      # Earl Grey hated the person who brought climbing rope.
      |> CSP.refute(suspect: :earl_grey, weapon: :climbing_rope)
      # Forensics determined a weapon made at least partially out of glass was present at the boutique hotel.
      |> CSP.assert(murdle, weapon: :snowglobe, location: :boutique_hotel)
      # The person who wanted to escape blackmail was in the gift shop.
      |> CSP.assert(murdle, motive: :escape_blackmail, location: :gift_shop)

    statements = [
      # Earl Grey: A snowglobe was at the boutique hotel.
      {:eary_grey, :assert, weapon: :snowglobe, location: :boutique_hotel},
      # Dr. Crimson: I did not bring a stone dagger.
      {:dr_crimson, :refute, suspect: :dr_crimson, weapon: :stone_dagger},
      # Secretary Celadon: Dr. Crimson was not in the gift shop.
      {:secretary_celadon, :refute, suspect: :dr_crimson, location: :gift_shop},
      # General Coffee: Argh... Dr. Crimson brought climbing rope.
      {:general_coffee, :assert, suspect: :dr_crimson, weapon: :climbing_rope}
    ]

    {suspect, state} = CSP.evaluate_statements(state, murdle, statements)

    assert :general_coffee == suspect

    assert %{weapon: [:murdle_vol_1], location: [:gift_shop], motive: [:escape_blackmail]} ==
             get_in(state, [:suspect, suspect])
  end

  test "Deductive Logico Cracks the Case of Exploding Cufflinks (2025-09-14)" do
    murdle = %{
      suspect: [
        :mx_tangerine,
        :principal_applegreen,
        :admiral_navy,
        :captain_slate,
        :baron_maroon,
        :general_coffee
      ],
      weapon: [
        :bottle_of_cabernet_toilet_wine,
        :pair_of_literal_golden_handcuffs,
        :rope_of_designer_clothes,
        :exploding_cufflinks,
        :diamond_encrusted_skeleton_key,
        :heavy_codebook
      ],
      location: [
        :movie_theater,
        :private_suite,
        :guard_tower,
        :spa,
        :tennis_court,
        :michelin_starred_cafeteria
      ]
    }

    state =
      murdle
      |> CSP.build_state()
      # A loose diamond was found next to a King-sized bed.
      |> CSP.assert(murdle, weapon: :diamond_encrusted_skeleton_key, location: :private_suite)
      # This fingerprint was found in the guard tower.
      |> CSP.assert(murdle, suspect: :mx_tangerine, location: :guard_tower)
      # The tallest suspect had a light-weight weapon.
      |> CSP.refute(
        suspect: :baron_maroon,
        weapon: [
          :bottle_of_cabernet_toilet_wine,
          :pair_of_literal_golden_handcuffs,
          :rope_of_designer_clothes,
          :heavy_codebook
        ]
      )
      # Admiral Navy had a bottle of cabernet toilet wine.
      |> CSP.assert(murdle, suspect: :admiral_navy, weapon: :bottle_of_cabernet_toilet_wine)
      # A page with a cipher on it was found next to a net.
      |> CSP.assert(murdle, weapon: :heavy_codebook, location: :tennis_court)
      # The other suspect with the same height as Mx. Tangerine had a rope of designer clothes.
      |> CSP.assert(murdle, suspect: :captain_slate, weapon: :rope_of_designer_clothes)
      # Baron Maroon was seen hanging around beneath the cushions of a velvet seat. (Decode.)
      |> CSP.assert(murdle, suspect: :baron_maroon, location: :movie_theater)
      # Admiral Navy had not been in the spa.
      |> CSP.refute(suspect: :admiral_navy, location: :spa)
      # Principal Applegreen was seen with a diamond-encrusted skeleton key.
      |> CSP.assert(murdle,
        suspect: :principal_applegreen,
        weapon: :diamond_encrusted_skeleton_key
      )
      |> CSP.propagate(murdle)

    # A single cufflink was found beside Inspector Irratino.
    assert %{location: [:movie_theater], suspect: [:baron_maroon]} ==
             get_in(state, [:weapon, :exploding_cufflinks])
  end
end
