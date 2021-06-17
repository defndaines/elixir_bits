defmodule Gigasecond do
  @doc """
  Calculate a date one billion seconds after an input date.
  """
  @spec from({{pos_integer, pos_integer, pos_integer}, {pos_integer, pos_integer, pos_integer}}) ::
          :calendar.datetime()

  def from(start_date = {{year, month, day}, {hours, minutes, seconds}}) do
    :calendar.datetime_to_gregorian_seconds(start_date) + 1_000_000_000
    |> :calendar.gregorian_seconds_to_datetime
  end
end
