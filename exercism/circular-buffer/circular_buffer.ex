defmodule CircularBuffer do
  @moduledoc """
  An API to a stateful process that fills and empties a circular buffer
  """

  defstruct [:capacity, buffer: %{}, head: 0, tail: 0]

  @doc """
  Create a new buffer of a given capacity
  """
  @spec new(capacity :: integer) :: {:ok, pid}
  def new(capacity), do: Agent.start(fn -> %__MODULE__{capacity: capacity} end)

  @doc """
  Read the oldest entry in the buffer, fail if it is empty
  """
  @spec read(buffer :: pid) :: {:ok, any} | {:error, atom}
  def read(buffer) do
    Agent.get_and_update(buffer, fn state ->
      if Enum.empty?(state.buffer) do
        {{:error, :empty}, state}
      else
        {value, buffer} = Map.pop(state.buffer, state.head)
        {{:ok, value}, %{state | buffer: buffer, head: rem(state.head + 1, state.capacity)}}
      end
    end)
  end

  @doc """
  Write a new item in the buffer, fail if is full
  """
  @spec write(buffer :: pid, item :: any) :: :ok | {:error, atom}
  def write(buffer, item) do
    Agent.get_and_update(buffer, fn state ->
      if Map.has_key?(state.buffer, state.tail) do
        {{:error, :full}, state}
      else
        buffer = Map.put(state.buffer, state.tail, item)
        {:ok, %{state | buffer: buffer, tail: rem(state.tail + 1, state.capacity)}}
      end
    end)
  end

  @doc """
  Write an item in the buffer, overwrite the oldest entry if it is full
  """
  @spec overwrite(buffer :: pid, item :: any) :: :ok
  def overwrite(buffer, item) do
    Agent.get_and_update(buffer, fn state ->
      {was, buffer} = Map.get_and_update(state.buffer, state.tail, &{&1, item})
      head = if was, do: rem(state.head + 1, state.capacity), else: state.head
      {:ok, %{state | buffer: buffer, head: head, tail: rem(state.tail + 1, state.capacity)}}
    end)
  end

  @doc """
  Clear the buffer
  """
  @spec clear(buffer :: pid) :: :ok
  def clear(buffer), do: Agent.get_and_update(buffer, &{:ok, %__MODULE__{capacity: &1.capacity}})
end
