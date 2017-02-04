defmodule Meetup do
  @moduledoc """
  Calculate meetup dates.
  """

  @type weekday ::
      :monday | :tuesday | :wednesday
    | :thursday | :friday | :saturday | :sunday

  @type schedule :: :first | :second | :third | :fourth | :last | :teenth

  @day_to_num %{ monday: 1, tuesday: 2, wednesday: 3,
    thursday: 4, friday: 5, saturday: 6, sunday: 7 }

  @doc """
  Calculate a meetup date.

  The schedule is in which week (1..4, last or "teenth") the meetup date should
  fall.
  """
  @spec meetup(pos_integer, pos_integer, weekday, schedule) :: :calendar.date
  def meetup(year, month, weekday, schedule) do
    check_from = period_start(schedule, year, month)
    day_of_week = Calendar.ISO.day_of_week(year, month, check_from)
    seeking = @day_to_num[weekday]
    {year, month, check_from + rem(7 + (seeking - day_of_week), 7)}
  end

  defp period_start(:first, _year, _month), do: 1
  defp period_start(:second, _year, _month), do: 8
  defp period_start(:third, _year, _month), do: 15
  defp period_start(:fourth, _year, _month), do: 22
  defp period_start(:teenth, _year, _month), do: 13
  defp period_start(:last, year, month) do
    Calendar.ISO.days_in_month(year, month) - 6
  end
end
