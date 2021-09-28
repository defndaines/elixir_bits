defmodule Lasagna do
  def expected_minutes_in_oven, do: 40

  def remaining_minutes_in_oven(minutes) do
    expected_minutes_in_oven() - minutes
  end

  def preparation_time_in_minutes(layers) do
    layers * 2
  end

  def total_time_in_minutes(layers, minutes_so_far) do
    minutes_so_far + preparation_time_in_minutes(layers)
  end

  def alarm, do: "Ding!"
end
