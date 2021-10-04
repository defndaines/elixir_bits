defmodule RemoteControlCar do
  @enforce_keys [:nickname]

  defstruct [
    :nickname,
    battery_percentage: 100,
    distance_driven_in_meters: 0
  ]

  def new(nickname \\ "none"), do: %__MODULE__{nickname: nickname}

  def display_distance(%__MODULE__{distance_driven_in_meters: distance}) do
    "#{distance} meters"
  end

  def display_battery(%__MODULE__{battery_percentage: 0}), do: "Battery empty"
  def display_battery(%__MODULE__{battery_percentage: pct}), do: "Battery at #{pct}%"

  def drive(%__MODULE__{battery_percentage: pct, distance_driven_in_meters: distance} = car)
      when pct > 0 do
    %{car | battery_percentage: pct - 1, distance_driven_in_meters: distance + 20}
  end

  def drive(%__MODULE__{} = car), do: car
end
