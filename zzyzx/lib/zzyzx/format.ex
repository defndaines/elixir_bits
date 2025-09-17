defmodule Zzyzx.Format do
  @moduledoc """
  Helper functions to aid in formatting text.
  """

  @ndash "\u2013"
  @mdash "\u2014"
  @lsquo "\u2018"
  @rsquo "\u2019"
  @ldquo "\u201C"
  @rdquo "\u201D"

  @doc """
  Format two date ranges, removing any repetitive information

  ## Examples

      iex> Zzyzx.Format.date_range(~D[2022-02-14], ~D[2022-02-28])
      "February 14 – 28, 2022"

      iex> Zzyzx.Format.date_range(~D[2022-02-28], ~D[2022-03-14])
      "February 28 – March 14, 2022"

      iex> Zzyzx.Format.date_range(~D[2021-12-06], ~D[2022-01-03])
      "December 6, 2021 – January 3, 2022"

  """
  def date_range(
        %Date{year: from_year, month: from_month} = from,
        %Date{year: to_year, month: to_month} = to
      )
      when from_year == to_year and from_month == to_month do
    [
      Calendar.strftime(from, "%B"),
      from.day,
      "–",
      Calendar.strftime(to, "%d, %Y") |> String.trim_leading("0")
    ]
    |> Enum.join(" ")
  end

  def date_range(%Date{year: from_year} = from, %Date{year: to_year} = to)
      when from_year == to_year do
    [
      Calendar.strftime(from, "%B"),
      from.day,
      "–",
      Calendar.strftime(to, "%B"),
      Calendar.strftime(to, "%d, %Y") |> String.trim_leading("0")
    ]
    |> Enum.join(" ")
  end

  def date_range(%Date{} = from, %Date{} = to) do
    [
      Calendar.strftime(from, "%B"),
      Calendar.strftime(from, "%d, %Y") |> String.trim_leading("0"),
      "–",
      Calendar.strftime(to, "%B"),
      Calendar.strftime(to, "%d, %Y") |> String.trim_leading("0")
    ]
    |> Enum.join(" ")
  end

  @doc """
  Generate a slug of ASCII text derived from text.

  Should remove any HTML entities (e.g., `&mdash;`) as well as HTML markup (e.g., `<strong>`). It
  should also handle any accented characters, e.g., converting "é" to a plain "e". The resulting
  slug is expected to be readable.
  """
  def slug(title) do
    title
    |> normalize_to_unicode()
    |> String.normalize(:nfd)
    |> String.downcase()
    |> String.replace(~r/&[^;]*;/, " ")
    |> String.replace(~r/<[^>]*>/, "")
    |> String.replace(["’", "'", "-", "—", ":"], " ")
    |> String.codepoints()
    |> Enum.filter(&String.match?(&1, ~r/[ a-z0-9]/))
    |> List.to_string()
    |> String.trim()
    |> String.replace(~r/\s+/, "-")
  end

  @unicode %{
    # Å   \u00C5  LATIN CAPITAL LETTER A WITH RING ABOVE
    "Â" => "\u00C5",
    # Á   \u00C1  LATIN CAPITAL LETTER A WITH ACUTE
    "Ã" => "\u00C1",
    "&Aacute;" => "\u00C1",
    # á   \u00E1  LATIN SMALL LETTER A WITH ACUTE
    "Ã¡" => "\u00E1",
    "&aacute;" => "\u00E1",
    # à   \u00E0  LATIN SMALL LETTER A WITH GRAVE
    "Ã " => "\u00E0",
    # â   \u00E2  LATIN SMALL LETTER A WITH CIRCUMFLEX
    "Ãƒ" => "\u00E2",
    "&acirc;" => "\u00E2",
    # â ... One occurrence is right after the above, causing "ââ"
    "Â¢" => "",
    # ã   \u00E3  LATIN SMALL LETTER A WITH TILDE
    "Ã£" => "\u00E3",
    # Ç   \u00C7  LATIN CAPITAL LETTER C WITH CEDILLA
    "Ã‡" => "\u00C7",
    "&Ccedil;" => "\u00C7",
    # ç   \u00E7  LATIN SMALL LETTER C WITH CEDILLA
    "Ã§" => "\u00E7",
    "&ccedil;" => "\u00E7",
    # É   \u00C9  LATIN CAPITAL LETTER E WITH ACUTE
    "Ã" => "\u00C9",
    "Ã‰" => "\u00C9",
    "&Eacute;" => "\u00C9",
    # é   \u00E9  LATIN SMALL LETTER E WITH ACUTE
    "Ãˆ" => "\u00E9",
    "Ã©" => "\u00E9",
    "&eacute;" => "\u00E9",
    # è   \u00E8  LATIN SMALL LETTER E WITH GRAVE
    "Ã¨" => "\u00E8",
    "&egrave;" => "\u00E8",
    # ë   \u00EB  LATIN SMALL LETTER E WITH DIAERESIS
    "Ã«" => "\u00EB",
    "&euml;" => "\u00EB",
    # ê   \u00EA  LATIN SMALL LETTER E WITH CIRCUMFLEX
    "Ãª" => "\u00EA",
    # ē   \u0113  LATIN SMALL LETTER E WITH MACRON
    "Ä“" => "\u0113",
    # í   \u00ED  LATIN SMALL LETTER I WITH ACUTE
    "Ã­" => "\u00ED",
    "&iacute;" => "\u00ED",
    # î   \u00EE  LATIN SMALL LETTER I WITH CIRCUMFLEX
    "Ã®" => "\u00EE",
    # ï   \u00EF  LATIN SMALL LETTER I WITH DIAERESIS
    "Ã¯" => "\u00EF",
    "&iuml;" => "\u00EF",
    # ñ   \u00F1  LATIN SMALL LETTER N WITH TILDE
    "Ã±" => "\u00F1",
    "&ntilde;" => "\u00F1",
    # ó   \u00F3  LATIN SMALL LETTER O WITH ACUTE
    "Ã³" => "\u00F3",
    "&oacute;" => "\u00F3",
    # ô   \u00F4  LATIN SMALL LETTER O WITH CIRCUMFLEX
    "Ã´" => "\u00F4",
    "&ocirc;" => "\u00F4",
    # Ö   \u00D6  LATIN CAPITAL LETTER O WITH DIAERESIS
    "&Ouml;" => "\u00D6",
    # ö   \u00F6  LATIN SMALL LETTER O WITH DIAERESIS
    "Ã¶" => "\u00F6",
    "&ouml;" => "\u00F6",
    # œ   \u0153  LATIN SMALL LIGATURE OE
    "Å“" => "\u0153",
    # ş   \u015F  LATIN SMALL LETTER S WITH CEDILLA
    "ÅŸ" => "\u015F",
    # ú   \u00FA  LATIN SMALL LETTER U WITH ACUTE
    "Ãº" => "\u00FA",
    "&uacute;" => "\u00FA",
    # û   \u00FB  LATIN SMALL LETTER U WITH CIRCUMFLEX
    "Ã»" => "\u00FB",
    # ü   \u00FC   LATIN SMALL LETTER U WITH DIAERESIS
    "Ã¼" => "\u00FC",
    "Â¼" => "\u00FC",
    "&uuml;" => "\u00FC",
    # °   \u00B0  DEGREE SIGN
    "Â°" => "\u00B0",
    "&deg;" => "\u00B0",
    "&ordm;" => "\u00B0",
    # ℉   \u2109   DEGREE FAHRENHEIT
    "&#8457;" => "\u2109",
    # ‐   \u2010   HYPHEN
    # ‐   \u2011   NON-BREAKING HYPHEN
    "â€‘" => "-",
    "&#8209;" => "-",
    # –   \u2013   EN DASH
    "&ndash;" => @ndash,
    # —   \u2014   EM DASH
    "â€“" => @mdash,
    "â€”" => @mdash,
    "Â€“" => @mdash,
    " -- " => @mdash,
    "&mdash;" => @mdash,
    # ‘   \u2018   LEFT SINGLE QUOTATION MARK
    "â€˜" => @lsquo,
    "&lsquo;" => @lsquo,
    # ’   \u2019   RIGHT SINGLE QUOTATION MARK
    "â€™" => @rsquo,
    "&rsquo;" => @rsquo,
    # “   \u201C   LEFT DOUBLE QUOTATION MARK
    "â€œ" => @ldquo,
    "&ldquo;" => @ldquo,
    # ”   \u201D   RIGHT DOUBLE QUOTATION MARK
    "â€" => @rdquo,
    " »" => @rdquo,
    "&rdquo;" => @rdquo,
    # …   \u2026   HORIZONTAL ELLIPSIS
    "â€¦" => "\u2026",
    "&hellip;" => "\u2026",
    # ¼   U+00BC  VULGAR FRACTION ONE QUARTER
    "&frac14;" => "\u00BC",
    # ½   \u00BD  VULGAR FRACTION ONE HALF
    "Â½" => "\u00BD",
    "&frac12;" => "\u00BD",
    # ¢   \u00A2  CENT SIGN
    "&cent;" => "\u00A2",
    # £   \u00A3  POUND SIGN
    "Å" => "\u00A3",
    "Â£" => "\u00A3",
    "&pound;" => "\u00A3",
    # €   \u20AC   EURO SIGN
    "â‚¬" => "\u20AC",
    # •   \u2022   BULLET
    "â—" => "\u2022",
    "&bull;" => "\u2022"
  }

  def normalize_to_unicode(text) do
    text
    |> String.replace(Map.keys(@unicode), &Map.get(@unicode, &1))
    |> String.replace(~r/([[:digit:]])\s*–\s*([[:digit:]])/, "\\1#{@ndash}\\2")
    |> String.replace(~r/\s*–\s*/, @ndash)
    |> String.replace(~r/\s*—\s*/, @mdash)
    |> String.replace(~r/([[:alnum:]])\\'/, "\\1#{@rsquo}")
    |> String.replace("\\'", @lsquo)
  end

  @doc """
  Use HTML entity to represent ellipses present in text.
  """
  def ellipses(text) do
    String.replace(text, ~r/\.\.\./, "&hellip;")
  end

  @doc """
  Normalize any `text` containing non-standard character sequences to something which can be read
  by mere mortals.
  """
  def normalize(text) do
    normalize_non_ascii(text)
  end

  defp normalize_non_ascii(text) do
    garble = [
      # left double quote
      ~r/â€œ/,
      @ldquo,
      # right double quote
      ~r/â€/,
      @rdquo,
      # right single quote
      ~r/â€™/,
      @rsquo,
      # left single quote
      ~r/â€˜/,
      @lsquo,
      # right single quote
      ~r/Âf/,
      @rsquo,
      # em dash
      ~r/\s*â€”\s*/,
      @mdash,
      # en dash
      ~r/\s*â€“\s*/,
      @ndash,
      # hyphen
      ~r/â€‘/,
      "-",
      # whitespace
      ~r/\s*Â \s*/,
      " ",
      # degree sign
      ~r/Â°/,
      "\u00B0",
      # ellipsis (NOTE: Unicode not presented consistently)
      ~r/â€¦/,
      "&hellip;",
      # bullet
      ~r/â—/,
      "\u2022",
      # 1/2 fraction
      ~r/Â½ \s*/,
      "\u00BD ",
      # c with cedilla
      ~r/Ã§/,
      "\u00E7",
      # British Pound
      ~r/Â£/,
      "\u00A3",
      # Cent sign
      ~r/Â¢/,
      "\u00A2",
      # Euro symbol
      ~r/â‚¬/,
      "\u20AC"
    ]

    Enum.chunk_every(garble, 2)
    |> Enum.reduce(text, fn [regex, utf], acc ->
      String.replace(acc, regex, utf)
    end)
  end

  # Includes articles, coordinating conjunctions, subordinating conjunctions, and prepositions.
  #
  # Technically, some of these words should be capitalized if used as adjectives or adverbs.
  # For example, "Give In to Me", "School‘s Out Forever", "Picking Up the Pieces", "Life Is But a
  # Dream", "Stand By for Action".
  @to_lower ~w(
    a an the
    and but for nor or so yet
    as if
    aboard about above abreast absent across after against ago along aloft alongside amid amidst
    among apropos around astride at atop before behind below beneath beside besides between
    beyond by circa cum despite during except from in including inside into notwithstanding of
    off on onto out over per pre sans since than through throughout to toward towards under
    underneath unlike until unto upon versus vs. v. via vis-à-vis with within without
           )

  @complex [
    "À La",
    "According to",
    "Ahead of",
    "Apart from",
    "as Regards",
    "as Soon as",
    "as Well as",
    "Aside from",
    "Away from",
    "Back to",
    "Because of",
    "Close to",
    "Counter to",
    "Due to",
    "Far from",
    "in Case",
    "Instead of",
    "Near to",
    "Opposite of",
    "Other than",
    "Outside of",
    "Owing to",
    "per Pro",
    "Pertaining to",
    "Prior to",
    "Pursuant to",
    "Rather than",
    "Regardless of",
    "Round about",
    "Subsequent to",
    "Such as"
  ]

  @doc """
  Format the provided string to title case. Title case capitalizes all important words, but
  doesn't capitalize prepositions or articles unless they are in an important position.
  """
  def title_case(string) do
    string
    |> normalize_to_unicode()
    |> fix_dashes()
    |> String.split()
    |> Enum.map_join(" ", &capitalize/1)
    |> complex_prepositions()
    |> capitalize_chunks()
    |> capitalize_end()
  end

  defp capitalize(string) when string in @to_lower, do: string
  defp capitalize("iP" <> _ = string), do: string
  defp capitalize("d’" <> _ = string), do: string
  defp capitalize("“" <> string), do: "“" <> :string.titlecase(string)
  defp capitalize("\"" <> string), do: "\"" <> :string.titlecase(string)
  defp capitalize("‘" <> string), do: "‘" <> :string.titlecase(string)
  defp capitalize("'" <> string), do: "'" <> :string.titlecase(string)

  defp capitalize(string) do
    down = String.downcase(string)

    if String.replace(down, ~r/[[:punct:]]+/, "") in @to_lower do
      down
    else
      :string.titlecase(string)
    end
  end

  defp complex_prepositions(string) do
    if String.contains?(string, @complex) do
      String.replace(string, @complex, &String.downcase/1)
    else
      string
    end
  end

  @punct [". ", "? ", "! ", ": ", "—"]

  defp capitalize_chunks(string) do
    @punct
    |> Enum.reduce(string, fn e, acc ->
      if String.contains?(acc, e) do
        acc
        |> String.split(e)
        |> Enum.map(&String.trim/1)
        |> Enum.map_join(e, &capitalize/1)
      else
        acc
      end
    end)
    |> capitalize()
  end

  defp capitalize_end(string) do
    if string |> String.replace(~r/[[:punct:]]+/, "") |> String.ends_with?(@to_lower) do
      chunks = String.split(string)
      last = chunks |> List.last() |> String.replace(~r/[[:punct:]]+/, "")

      if last in @to_lower do
        chunks
        |> List.replace_at(-1, chunks |> List.last() |> String.capitalize())
        |> Enum.join(" ")
      else
        string
      end
    else
      string
    end
  end

  @dashes ["-", "–", "—"]

  defp fix_dashes(string) do
    if String.contains?(string, @dashes) do
      string
      |> String.replace("–", "—")
      |> String.replace(~r/(\d)[—-](\d)/, "\\1–\\2")
    else
      string
    end
  end
end
