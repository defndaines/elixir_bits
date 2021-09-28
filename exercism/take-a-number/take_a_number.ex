defmodule TakeANumber do
  def start(), do: spawn(&loop/0)

  defp loop(state \\ 0) do
    receive do
      {:report_state, caller} ->
        send(caller, state)
        loop(state)

      {:take_a_number, caller} ->
        number = state + 1
        send(caller, number)
        loop(number)

      :stop ->
        :ok

      _ ->
        loop(state)
    end
  end
end
