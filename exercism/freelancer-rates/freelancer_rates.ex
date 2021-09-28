defmodule FreelancerRates do
  def daily_rate(hourly_rate), do: hourly_rate * 8.0

  def apply_discount(before_discount, discount) do
    before_discount * ((100 - discount) / 100)
  end

  def monthly_rate(hourly_rate, discount) do
    hourly_rate
    |> daily_rate()
    |> Kernel.*(22.0)
    |> apply_discount(discount)
    |> Float.ceil()
    |> Kernel.trunc()
  end

  def days_in_budget(budget, hourly_rate, discount) do
    rate = hourly_rate |> daily_rate() |> apply_discount(discount)
    Float.floor(budget / rate, 1)
  end
end
