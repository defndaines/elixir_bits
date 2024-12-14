defmodule SecretHandshake do
  @doc """
  Determine the actions of a secret handshake based on the binary
  representation of the given `code`.

  If the following bits are set, include the corresponding action in your list
  of commands, in order from lowest to highest.

  1 = wink
  10 = double blink
  100 = close your eyes
  1000 = jump

  10000 = Reverse the order of the operations in the secret handshake
  """
  import Bitwise

  @spec commands(code :: integer) :: list(String.t())
  def commands(code) do
    Enum.reduce(
      [
        &if(band(code, 1) > 0, do: ["wink" | &1], else: &1),
        &if(band(code, 2) > 0, do: ["double blink" | &1], else: &1),
        &if(band(code, 4) > 0, do: ["close your eyes" | &1], else: &1),
        &if(band(code, 8) > 0, do: ["jump" | &1], else: &1),
        &if(band(code, 16) > 0, do: &1, else: Enum.reverse(&1))
      ],
      [],
      fn f, acc -> f.(acc) end
    )
  end
end
