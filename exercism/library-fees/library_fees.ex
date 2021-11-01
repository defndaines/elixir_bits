defmodule LibraryFees do
  def datetime_from_string(string), do: NaiveDateTime.from_iso8601!(string)

  def before_noon?(datetime), do: NaiveDateTime.to_time(datetime) < Time.new!(12, 0, 0)

  def return_date(checkout_datetime) do
    checkout_datetime
    |> NaiveDateTime.to_date()
    |> Date.add(if before_noon?(checkout_datetime), do: 28, else: 29)
  end

  def days_late(planned_return_date, actual_return_datetime) do
    actual_return_datetime
    |> NaiveDateTime.to_date()
    |> Date.diff(planned_return_date)
    |> max(0)
  end

  def monday?(datetime) do
    1 == datetime |> NaiveDateTime.to_date() |> Date.day_of_week()
  end

  def calculate_late_fee(checkout, return, rate) do
    due_date = checkout |> datetime_from_string() |> return_date()
    return_date = datetime_from_string(return)
    fee_rate = if monday?(return_date), do: rate * 0.5, else: rate
    floor(days_late(due_date, return_date) * fee_rate)
  end
end
