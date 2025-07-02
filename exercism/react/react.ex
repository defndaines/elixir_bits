defmodule React do
  use GenServer

  @opaque cells :: pid

  @type cell :: {:input, String.t(), any} | {:output, String.t(), [String.t()], fun()}

  @doc """
  Start a reactive system
  """
  @spec new(cells :: [cell]) :: {:ok, pid}
  def new(cells), do: GenServer.start(__MODULE__, cells)

  @doc """
  Return the value of an input or output cell
  """
  @spec get_value(cells :: pid, cell_name :: String.t()) :: any()
  def get_value(cells, cell_name), do: GenServer.call(cells, {:get_value, cell_name})

  @doc """
  Set the value of an input cell
  """
  @spec set_value(cells :: pid, cell_name :: String.t(), value :: any) :: :ok
  def set_value(cells, cell_name, value) do
    GenServer.call(cells, {:set_value, cell_name, value})
  end

  @doc """
  Add a callback to an output cell
  """
  @spec add_callback(
          cells :: pid,
          cell_name :: String.t(),
          callback_name :: String.t(),
          callback :: fun()
        ) :: :ok
  def add_callback(cells, cell_name, callback_name, callback) do
    GenServer.call(cells, {:add_callback, cell_name, callback_name, callback})
  end

  @doc """
  Remove a callback from an output cell
  """
  @spec remove_callback(cells :: pid, cell_name :: String.t(), callback_name :: String.t()) :: :ok
  def remove_callback(cells, cell_name, callback_name) do
    GenServer.call(cells, {:remove_callback, cell_name, callback_name})
  end

  @impl GenServer
  def init(cells), do: {:ok, init_state(cells)}

  defp init_state(cells, state \\ %{callbacks: %{}, triggers: %{}})
  defp init_state([], state), do: state

  defp init_state([{:input, key, value} | rest], state) do
    init_state(rest, Map.put(state, key, value))
  end

  defp init_state([{:output, key, args, fun} | rest], state) do
    triggers =
      Enum.reduce(args, state.triggers, fn e, acc ->
        Map.update(acc, e, [key], &[key | &1])
      end)

    init_state(rest, state |> Map.put(key, {fun, args}) |> Map.put(:triggers, triggers))
  end

  @impl GenServer
  def handle_call({:get_value, cell_name}, _, state) do
    {:reply, calculate(Map.get(state, cell_name), state), state}
  end

  def handle_call({:set_value, cell_name, value}, _, state) do
    updated = Map.put(state, cell_name, value)
    handle_triggers(state, updated, cell_name)
    {:reply, :ok, updated}
  end

  def handle_call({:add_callback, cell_name, callback_name, callback}, _, state) do
    callbacks =
      Map.update(
        state.callbacks,
        cell_name,
        [{callback_name, callback}],
        &[{callback_name, callback} | &1]
      )

    {:reply, :ok, Map.put(state, :callbacks, callbacks)}
  end

  def handle_call({:remove_callback, cell_name, callback_name}, _, state) do
    callbacks = Map.update(state.callbacks, cell_name, [], &List.keydelete(&1, callback_name, 0))
    {:reply, :ok, Map.put(state, :callbacks, callbacks)}
  end

  defp calculate({fun, args}, state) do
    apply(fun, Enum.map(args, &calculate(Map.get(state, &1), state)))
  end

  defp calculate(value, _), do: value

  defp handle_triggers(old_state, new_state, cell_name) do
    if triggers = get_in(old_state, [:triggers, cell_name]) do
      callbacks = triggers |> Enum.map(&get_in(old_state, [:callbacks, &1])) |> Enum.filter(& &1)

      if not Enum.empty?(callbacks) do
        Enum.each(triggers, fn cell_name ->
          latter = calculate(Map.get(new_state, cell_name), new_state)

          if latter != calculate(Map.get(old_state, cell_name), old_state) do
            for {callback_name, callback} <- get_in(old_state, [:callbacks, cell_name]) do
              callback.(callback_name, latter)
            end
          end
        end)
      end
    end
  end
end
