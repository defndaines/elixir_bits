defmodule DateParser do
  def day(), do: "([0-2 ]?\\d|3[01])"

  def month(), do: "([0 ]?\\d|1[012])"

  def year(), do: "((19|20)\\d{2})"

  def day_names(), do: "((Mon|Tues|Wednes|Thurs|Fri|Satur|Sun)day)"

  def month_names() do
    "((Jan|Febr)uary|March|April|May|Ju(ne|ly)|August|(Octo|(Sept|Nov|Dec)em)ber)"
  end

  def capture_day(), do: "(?<day>#{day()})"

  def capture_month(), do: "(?<month>#{month()})"

  def capture_year(), do: "(?<year>#{year()})"

  def capture_day_name(), do: "(?<day_name>#{day_names()})"

  def capture_month_name(), do: "(?<month_name>#{month_names()})"

  def capture_numeric_date(), do: Enum.join([capture_day(), capture_month(), capture_year()], "/")

  def capture_month_name_date(), do: "#{capture_month_name()} #{capture_day()}, #{capture_year()}"

  def capture_day_month_name_date(), do: "#{capture_day_name()}, #{capture_month_name_date()}"

  def match_numeric_date(), do: Regex.compile!("^#{capture_numeric_date()}$")

  def match_month_name_date(), do: Regex.compile!("^#{capture_month_name_date()}$")

  def match_day_month_name_date(), do: Regex.compile!("^#{capture_day_month_name_date()}$")
end
