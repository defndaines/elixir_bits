defmodule BirdCount do
  def today([]), do: nil
  def today([today | _]), do: today

  def increment_day_count([]), do: [1]
  def increment_day_count([today | rest]), do: [today + 1 | rest]

  def has_day_without_birds?([]), do: false
  def has_day_without_birds?([0 | _]), do: true
  def has_day_without_birds?([_ | rest]), do: has_day_without_birds?(rest)

  def total(list, acc \\ 0)
  def total([], acc), do: acc
  def total([birds | rest], acc), do: total(rest, acc + birds)

  def busy_days(list, acc \\ 0)
  def busy_days([], acc), do: acc
  def busy_days([birds | rest], acc) when birds >= 5, do: busy_days(rest, acc + 1)
  def busy_days([_ | rest], acc), do: busy_days(rest, acc)
end
