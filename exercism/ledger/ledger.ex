defmodule Ledger do
  @type currency :: :usd | :eur
  @type locale :: :en_US | :nl_NL
  @type entry :: %{amount_in_cents: integer(), date: Date.t(), description: String.t()}

  @doc """
  Format the given entries given a currency and locale
  """
  @spec format_entries(currency(), locale(), list(entry())) :: String.t()
  def format_entries(currency, locale, entries) do
    Enum.join(
      [
        header(locale)
        | entries
          |> Enum.sort_by(&{&1.date.day, &1.description, &1.amount_in_cents})
          |> Enum.map(fn entry -> format_entry(currency, locale, entry) end)
      ],
      "\n"
    ) <> "\n"
  end

  defp format_line(cells) do
    cells |> Enum.zip_with([10, 25, 13], &format_cell/2) |> Enum.join(" | ")
  end

  defp format_cell(data, len) do
    if String.length(data) > len do
      String.slice(data, 0, len - 3) <> "..."
    else
      String.pad_trailing(data, len, " ")
    end
  end

  defp header(:en_US), do: format_line(~w(Date Description Change))
  defp header(_), do: format_line(~w(Datum Omschrijving Verandering))

  defp format_date(:en_US, date), do: Calendar.strftime(date, "%m/%d/%Y")
  defp format_date(_, date), do: Calendar.strftime(date, "%d-%m-%Y")

  defp format_money(currency, locale, cents) do
    currency_symbol = if currency == :eur, do: "€", else: "$"

    {dec_sep, thou_sep} = if locale == :en_US, do: {".", ","}, else: {",", "."}
    whole = cents |> abs() |> div(100) |> format_integer(thou_sep)
    decimal = cents |> abs() |> rem(100) |> to_string() |> String.pad_leading(2, "0")
    number = whole <> dec_sep <> decimal

    # To ensure that decimals align, adds space to end when ")" not present.
    case {locale, cents >= 0} do
      {:en_US, true} -> "#{currency_symbol}#{number} "
      {:en_US, false} -> "(#{currency_symbol}#{number})"
      {_, true} -> "#{currency_symbol} #{number} "
      {_, false} -> "#{currency_symbol} -#{number} "
    end
  end

  defp format_integer(n, _) when n < 1000, do: "#{n}"

  defp format_integer(n, separator) do
    "#{div(n, 1000)}" <> separator <> format_integer(rem(n, 1000), separator)
  end

  defp format_entry(currency, locale, entry) do
    format_line([
      format_date(locale, entry.date),
      entry.description,
      currency |> format_money(locale, entry.amount_in_cents) |> String.pad_leading(13, " ")
    ])
  end
end
