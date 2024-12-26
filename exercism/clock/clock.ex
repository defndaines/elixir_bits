defmodule Clock do
  defstruct hour: 0, minute: 0

  @doc """
  Returns a clock that can be represented as a string:

      iex> Clock.new(8, 9) |> to_string
      "08:09"
  """
  @spec new(integer, integer) :: Clock
  def new(hour, minute) when minute >= 60, do: new(hour + div(minute, 60), rem(minute, 60))
  def new(hour, minute) when minute < 0, do: new(hour - 1, 60 + minute)
  def new(hour, minute) when hour >= 24, do: new(rem(hour, 24), minute)
  def new(hour, minute) when hour < 0, do: new(24 + hour, minute)
  def new(hour, minute), do: %__MODULE__{hour: hour, minute: minute}

  @doc """
  Adds two clock times:

      iex> Clock.new(10, 0) |> Clock.add(3) |> to_string
      "10:03"
  """
  @spec add(Clock, integer) :: Clock
  def add(clock, add_minute), do: new(clock.hour, clock.minute + add_minute)

  defimpl String.Chars do
    def to_string(clock) do
      [clock.hour, clock.minute]
      |> Enum.map(&(&1 |> Integer.to_string() |> String.pad_leading(2, "0")))
      |> Enum.join(":")
    end
  end
end
