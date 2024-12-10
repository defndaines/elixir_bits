defmodule RPNCalculatorInspection do
  @timeout_ms 100

  def start_reliability_check(calculator, input) do
    %{input: input, pid: spawn_link(fn -> calculator.(input) end)}
  end

  def await_reliability_check_result(%{pid: pid, input: input}, results) do
    result =
      receive do
        {:EXIT, ^pid, :normal} -> :ok
        {:EXIT, ^pid, _} -> :error
      after
        @timeout_ms -> :timeout
      end

    Map.put(results, input, result)
  end

  def reliability_check(calculator, inputs) do
    trap_exit? = Process.flag(:trap_exit, true)

    inputs
    |> Enum.map(&start_reliability_check(calculator, &1))
    |> Enum.reduce(%{}, &await_reliability_check_result/2)
    |> tap(fn _ -> Process.flag(:trap_exit, trap_exit?) end)
  end

  def correctness_check(calculator, inputs) do
    inputs
    |> Enum.map(&Task.async(fn -> calculator.(&1) end))
    |> Enum.map(&Task.await(&1, @timeout_ms))
  end
end
