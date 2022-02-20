defmodule Life do
  @moduledoc """
  Conway's Game of Life as a GenServer.
  """

  use GenServer

  @dead 0
  @live 1

  ## Client

  def start(grid) when is_list(grid) do
    {:ok, pid} = GenServer.start(__MODULE__, Array.from_list(grid))
    pid
  end

  def stop(pid) do
    GenServer.stop(pid, :normal)
  end

  def age(pid) do
    GenServer.cast(pid, :age)
  end

  @spec state(pid()) :: [[integer]]
  def state(pid) do
    GenServer.call(pid, :state)
  end

  ## Server (callbacks)

  @impl GenServer
  def init(grid), do: {:ok, grid}

  @impl GenServer
  def handle_cast(:age, state) do
    {:noreply, step(state)}
  end

  @impl GenServer
  def handle_call(:state, _, state) do
    {:reply, Array.to_list(state), state}
  end

  ## Private

  defp step(array) do
    array
    # :array.foldr(fn x, row, acc ->
    # :array.set(x, :array.foldr(fn y, v, acc ->
    # case apply_rule(array, {x, y}) do
    # v -> acc
    # new_value -> :array.set(y, new_value, acc)
    # end
    # end, acc, row), acc)
    # end, array, array)
  end

  # Rules
  # - Any live cell with two or three live neighbors survives.
  # - Any dead cell with three live neighbors becomes a live cell.
  # - All other live cells die in the next generation. Similarly, all other dead cells stay dead.
  def apply_rule(array, {x, y}) do
    status = Array.get(array, {x, y})
    live_neighbors = Array.neighbors(array, {x, y})

    case status do
      @live -> if live_neighbors in [2, 3], do: @live, else: @dead
      @dead -> if live_neighbors == 3, do: @live, else: @dead
    end
  end
end
