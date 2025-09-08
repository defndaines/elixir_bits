defmodule React do
  @opaque cells :: pid

  @type cell :: {:input, String.t(), any} | {:output, String.t(), [String.t()], fun()}

  @doc """
  Start a reactive system
  """
  @spec new(cells :: [cell]) :: {:ok, pid}
  def new(cells), do: Agent.start_link(fn -> init_state(cells) end)

  @doc """
  Return the value of an input or output cell
  """
  @spec get_value(cells :: pid, cell_name :: String.t()) :: any()
  def get_value(cells, cell_name), do: Agent.get(cells, &calculate(&1, cell_name))

  @doc """
  Set the value of an input cell
  """
  @spec set_value(cells :: pid, cell_name :: String.t(), value :: any) :: :ok
  def set_value(cells, cell_name, value) do
    Agent.update(cells, fn state ->
      state.inputs[cell_name]
      |> put_in(value)
      |> tap(&Enum.each(&1.callbacks, fn callback -> notify(callback, state, &1) end))
    end)
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
    Agent.update(cells, &put_in(&1.callbacks[callback_name], {cell_name, callback}))
  end

  @doc """
  Remove a callback from an output cell
  """
  @spec remove_callback(cells :: pid, cell_name :: String.t(), callback_name :: String.t()) :: :ok
  def remove_callback(cells, _cell_name, callback_name) do
    Agent.update(cells, fn state ->
      {_, new_state} = pop_in(state.callbacks[callback_name])
      new_state
    end)
  end

  defp init_state(cells, state \\ %{inputs: %{}, outputs: %{}, callbacks: %{}})
  defp init_state([], state), do: state

  defp init_state([{:input, key, value} | rest], state) do
    init_state(rest, put_in(state.inputs[key], value))
  end

  defp init_state([{:output, key, args, fun} | rest], state) do
    init_state(rest, put_in(state.outputs[key], {fun, args}))
  end

  defp calculate(state, cell_name) do
    if value = state.inputs[cell_name] do
      value
    else
      {fun, args} = state.outputs[cell_name]
      apply(fun, Enum.map(args, &calculate(state, &1)))
    end
  end

  defp notify({callback_name, {cell_name, callback}}, old_state, new_state) do
    if (value = calculate(new_state, cell_name)) != calculate(old_state, cell_name) do
      callback.(callback_name, value)
    end
  end
end
