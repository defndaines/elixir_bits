defmodule Gigasecond do
  @doc """
  Calculate a date one billion seconds after an input date.
  """
  @spec from({{pos_integer, pos_integer, pos_integer}, {pos_integer, pos_integer, pos_integer}}) ::
          :calendar.datetime()

  def from(start_date = {{year, month, day}, {hours, minutes, seconds}}) do
    with {:ok, date} <- Date.new(year, month, day),
         {:ok, time} <- Time.new(hours, minutes, seconds),
         {:ok, date_time} <- DateTime.new(date, time, "Etc/UTC"),
         gs <- DateTime.add(date_time, 1_000_000_000) do
      {{gs.year, gs.month, gs.day}, {gs.hour, gs.minute, gs.second}}
    end
  end
end
