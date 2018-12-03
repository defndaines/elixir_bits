defmodule Day1 do
  def calibrate([], acc) do
    acc
  end
  def calibrate([head | tail], acc) do
    calibrate(tail, acc + head)
  end
end

ExUnit.start()

defmodule Day1Test do
  use ExUnit.Case

  import Day1

  test "input" do
    {:ok, input} = File.read("input")
    result = input
             |> String.split("\n", trim: true)
             |> Enum.map(&String.to_integer/1)
             |> calibrate(0)
    IO.puts(result)
  end
end
