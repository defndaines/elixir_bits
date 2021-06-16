defmodule BankAccount do
  @moduledoc """
  A bank account that supports access from multiple processes.
  """

  use GenServer

  @impl true
  def init(_), do: {:ok, 0}

  @impl true
  def handle_cast(_, state), do: {:noreply, state}

  @impl true
  def handle_call({:update, amount}, _, state), do: {:reply, :ok, state + amount}
  def handle_call({:balance}, _, state), do: {:reply, state, state}
  def handle_call(_, _, state), do: {:reply, state, state}

  @typedoc """
  An account handle.
  """
  @opaque account :: pid

  @doc """
  Open the bank. Makes the account available.
  """
  @spec open_bank() :: account
  def open_bank() do
    {:ok, pid} = GenServer.start(__MODULE__, nil)
    pid
  end

  @doc """
  Close the bank. Makes the account unavailable.
  """
  @spec close_bank(account) :: none
  def close_bank(account) do
    GenServer.stop(account, :normal)
  end

  @doc """
  Get the account's balance.
  """
  @spec balance(account) :: integer
  def balance(account) do
    if Process.alive?(account) do
      GenServer.call(account, {:balance})
    else
      {:error, :account_closed}
    end
  end

  @doc """
  Update the account's balance by adding the given amount which may be negative.
  """
  @spec update(account, integer) :: any
  def update(account, amount) do
    if Process.alive?(account) do
      GenServer.call(account, {:update, amount})
    else
      {:error, :account_closed}
    end
  end
end
