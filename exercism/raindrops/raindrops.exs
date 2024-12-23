defmodule Raindrops do
  @drops %{3 => ~c"Pling", 5 => ~c"Plang", 7 => ~c"Plong"}

  @doc """
  Returns a string based on raindrop factors.

  - If the number contains 3 as a prime factor, output 'Pling'.
  - If the number contains 5 as a prime factor, output 'Plang'.
  - If the number contains 7 as a prime factor, output 'Plong'.
  - If the number does not contain 3, 5, or 7 as a prime factor,
    just pass the number's digits straight through.
  """
  @spec convert(pos_integer) :: String.t()
  def convert(number) do
    case @drops |> Enum.map_join(fn {key, value} -> if rem(number, key) == 0, do: value end) do
      "" -> Integer.to_string(number)
      sound -> sound
    end
  end
end
