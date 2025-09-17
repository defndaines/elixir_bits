defmodule Zzyzx.FormatTest do
  use ExUnit.Case
  doctest Zzyzx.Format

  alias Zzyzx.Format

  describe "date_range/2" do
    test "single digit days in same month" do
      assert Format.date_range(~D[2022-05-01], ~D[2022-05-09]) == "May 1 – 9, 2022"
    end

    test "single digit days in different months" do
      assert Format.date_range(~D[2022-05-01], ~D[2022-06-01]) == "May 1 – June 1, 2022"
    end

    test "single digit days in different years" do
      assert Format.date_range(~D[2021-12-06], ~D[2022-01-03]) ==
               "December 6, 2021 – January 3, 2022"
    end
  end

  describe "slug/1" do
    test "replaces spaces with dashes" do
      assert Format.slug("a space between") == "a-space-between"
    end

    test "down-cases all letters" do
      assert Format.slug("wHo wRoTe tHiS") == "who-wrote-this"
    end

    test "compress multiple whitespaces to single dash" do
      assert Format.slug(" lots of spacing ") == "lots-of-spacing"
    end

    test "convert HTML entities" do
      assert Format.slug("Hey&mdash;There") == "hey-there"
    end

    test "removes any punctuation" do
      assert Format.slug("Next: \"That's\" what he said?") == "next-that-s-what-he-said"
    end

    test "handles garbled characters" do
      title = "Afghanistan: A â€œTragic Mistakeâ€ ... After Thousands of Others"
      assert Format.slug(title) == "afghanistan-a-tragic-mistake-after-thousands-of-others"
    end

    test "preserves letters in entities" do
      assert Format.slug("Ouvrière") == "ouvriere"
    end

    test "removes HTML tags" do
      assert Format.slug("<strong>Culture Corner</strong>") == "culture-corner"
      assert Format.slug("New Attack on <em>Row v. Wade</em>") == "new-attack-on-row-v-wade"
    end
  end

  describe "ellipses/1" do
    test "leaves regular text alone" do
      assert Format.ellipses("U.S. left alone") == "U.S. left alone"
    end

    test "converts three periods to ellipses" do
      assert Format.ellipses("and ... then") == "and &hellip; then"
    end

    test "when ellipses ends sentence" do
      assert Format.ellipses("fall....") == "fall&hellip;."
    end

    test "convert multiple ellipses" do
      assert Format.ellipses("and ... then ... off") == "and &hellip; then &hellip; off"
    end
  end

  describe "normalize/1" do
    test "double quotes" do
      text =
        "<p>â— â€œUAW leadershipâ€™s credibility evaporating with new charges,â€</p>"

      assert Format.normalize(text) ==
               "<p>• “UAW leadership’s credibility evaporating with new charges,”</p>"
    end

    test "single quotes" do
      assert Format.normalize("was â€˜simplyâ€™ more") == "was ‘simply’ more"
    end

    test "em dashes" do
      text = "ideology â€” the so-called"
      assert Format.normalize(text) == "ideology—the so-called"
    end

    test "en dashes between numbers" do
      assert Format.normalize("1947 â€“ 1950") == "1947–1950"
    end

    test "en dashes not between numbers" do
      text = "1947 â€“ and a"
      assert Format.normalize(text) == "1947–and a"
    end

    test "non-standard hyphens" do
      text = "pseudoâ€‘democratic faÃ§ade"
      assert Format.normalize(text) == "pseudo-democratic façade"
    end

    test "degrees" do
      text = "over 100Â°F, this"
      assert Format.normalize(text) == "over 100°F, this"
    end

    test "ellipsis" do
      text = "<h2>â€¦ Which Remains"
      assert Format.normalize(text) == "<h2>&hellip; Which Remains"
    end

    test "half" do
      text = "for 3Â½ years."
      assert Format.normalize(text) == "for 3½ years."
    end

    test "pound" do
      text = "costs Â£100,000 ($185,000)"
      assert Format.normalize(text) == "costs £100,000 ($185,000)"
    end

    test "euros" do
      text = "and â‚¬5,000!"
      assert Format.normalize(text) == "and €5,000!"
    end

    test "cents" do
      text = "of 32Â¢ in Cost-of-Living"
      assert Format.normalize(text) == "of 32¢ in Cost-of-Living"
    end
  end

  describe "title_case/1" do
    test "with no prepositions" do
      truth = [
        "truth be told",
        "Truth be told",
        "Truth Be Told"
      ]

      assert ["Truth Be Told"] == truth |> Enum.map(&Format.title_case/1) |> Enum.uniq()
    end

    test "with legitimate uppercasing mid-word" do
      assert "Japan: OKs Divorce Bill" == Format.title_case("Japan: OKs divorce bill")
    end

    test "with emdash" do
      assert "Korea—Not Just Delicious Food" == Format.title_case("Korea—Not just delicious food")
      assert "U.S.—A Country in Turmoil" == Format.title_case("U.S.—a country in turmoil")
    end

    test "with is in it" do
      assert "This Is It!" == Format.title_case("This is it!")
    end

    test "with non-ASCII in it" do
      assert "Éowyn’s Résumé" == Format.title_case("éowyn’s résumé")
    end

    test "prepositions" do
      assert "It's the End of the World as We Know It" ==
               Format.title_case("it's the end of the world as we know it")
    end

    test "complex prepositions" do
      assert "Life according to You Is outside of Material Goods" ==
               Format.title_case("life according to you is outside of material goods")
    end

    test "preposition and articles at the beginning" do
      assert "To Address the Problem" == Format.title_case("to address the problem")
      assert "The Problem to Address" == Format.title_case("the problem to address")
    end

    test "capitalize after colons" do
      assert "Empathy: An Answer to Hate?" == Format.title_case("empathy: an answer to hate?")
    end

    test "handles extra spaces" do
      assert "Beneath the Planet of the Apes" ==
               Format.title_case("beneath  the  planet   of  the apes")
    end

    test "handles purposefully lowercase initial letters" do
      assert "The New iPhone" == Format.title_case("the new iPhone")
    end

    test "downcases prepositions" do
      assert "Beneath the Planet of the Apes" ==
               Format.title_case("Beneath The Planet Of The Apes")
    end

    test "handles punctuation" do
      assert ~s(Will the U.S. Be “Many Years” in Iraq?) ==
               Format.title_case(~s(Will the U.S. Be &ldquo;many Years&rdquo; in Iraq?))

      assert ~s(Will the U.S. Be "Many Years" in Iraq?) ==
               Format.title_case(~s(Will the U.S. Be "many Years" in Iraq?))

      assert ~s(Will the U.S. Be 'Many Years' in Iraq?) ==
               Format.title_case(~s(Will the U.S. Be 'many Years' in Iraq?))

      assert ~s(Will the U.S. Be ‘Many Years’ in Iraq?) ==
               Format.title_case(~s(Will the U.S. Be &lsquo;many Years&rsquo; in Iraq?))
    end

    test "apple products and coup d&lsquo;&eacute;tats are special" do
      assert "iPads and iPhones in the Coup d’État" ==
               Format.title_case("iPads And iPhones In The Coup d&rsquo;&Eacute;tat")
    end

    test "downcase with punctuation" do
      assert "Which Side Are You on, Bob?" == Format.title_case("Which Side Are You On, Bob?")
    end

    test "handle dashes" do
      assert "Two New Years—One for the Rich and One for the Poor" ==
               Format.title_case("Two new years &ndash; One for the rich and one for the poor")

      assert "Haiti: The Governor’s Island Agreement—A Pact between the Defenders of Bourgeois Order" ==
               Format.title_case(
                 "Haiti: the Governor&rsquo;s Island Agreement â€” A pact between the defenders of bourgeois order"
               )

      assert "Jerry Tucker, 1939–2012" == Format.title_case("Jerry Tucker, 1939-2012")

      assert "Riveting TV—The Wire: Seasons 1–5" ==
               Format.title_case("Riveting TV &ndash; The Wire: Seasons 1-5")
    end

    test "handle escaped quotes" do
      assert "You Can Be Safe, if You’ve Got Cash" ==
               Format.title_case("You can be safe, if you\\'ve got cash")

      assert "Who Says There’s No Conscription?" ==
               Format.title_case("Who says there\\'s no conscription?")

      assert "What ‘Family Values’?" == Format.title_case("What \\'family values\\'?")

      assert "“A Critical Tool”: Using People Who Lie for a Living" ==
               Format.title_case(
                 "&ldquo;A critical tool&rdquo;: Using people who lie for a living"
               )
    end

    test "last word capitalized" do
      assert "The Cracks Get Wider for People to Fall Through" ==
               Format.title_case("The Cracks Get Wider for People to Fall through")

      assert "Texas Tragedy: Blame the Bus Driver to Protect Others Higher Up" ==
               Format.title_case(
                 "Texas Tragedy: Blame the Bus Driver to Protect Others Higher up"
               )

      assert "Tax Day: The Rich Runneth Over" ==
               Format.title_case("Tax Day: The Rich Runneth over")

      assert "After the Elections Watch Out!" ==
               Format.title_case("After the elections watch out!")

      assert "2014 Elections: Distrustful, Dissatisfied and Fed Up!" ==
               Format.title_case("2014 Elections: Distrustful, Dissatisfied and Fed Up!")

      assert "Baltimore City: School’s Out?" == Format.title_case("Baltimore City: School’s out?")
    end

    test "capitalize words after punctuation" do
      assert "$26 Gold-plated Health Care? A Bold-as-brass Lie!" ==
               Format.title_case("$26 Gold-plated Health Care? a Bold-as-brass Lie!")

      assert "1,226 Billionaires on the Planet! A World of Inequalities" ==
               Format.title_case("1,226 Billionaires on the Planet! a World of Inequalities")

      assert "1935: Workers Were Organizing. The CIO Ran to Catch Up" ==
               Format.title_case("1935: Workers Were Organizing. the CIO Ran to Catch Up")

      assert "Heroes One Day—Despised the Next" ==
               Format.title_case("Heroes One Day—despised the Next")

      assert "One Year after the Great Power Blackout—Preparing for the Next One" ==
               Format.title_case(
                 "One Year after the Great Power Blackout—preparing for the next One"
               )

      assert "Barbarians Attack Women—Not Just in Pakistan" ==
               Format.title_case("Barbarians Attack Women—not Just in Pakistan")

      assert "Be All You Can Be—Without Health Care!" ==
               Format.title_case("Be All You Can Be—Without Health Care!")

      assert "Migrants Murdered in Saudi Arabia … and Elsewhere" ==
               Format.title_case("Migrants Murdered in Saudi Arabia … and Elsewhere")
    end
  end
end
