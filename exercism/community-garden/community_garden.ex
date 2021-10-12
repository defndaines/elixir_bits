# Use the Plot struct as it is provided
defmodule Plot do
  @enforce_keys [:plot_id, :registered_to]
  defstruct [:plot_id, :registered_to]
end

defmodule CommunityGarden do
  def start(opts \\ []), do: Agent.start(fn -> [] end, opts)

  def list_registrations(pid), do: Agent.get(pid, &Function.identity/1)

  def register(pid, register_to) do
    plot = %Plot{plot_id: "?", registered_to: register_to}
    Agent.update(pid, fn plots -> [plot | plots] end)
    plot
  end

  def release(pid, plot_id) do
    Agent.update(pid, fn plots ->
      Enum.reject(plots, fn %Plot{plot_id: test_id} -> test_id == plot_id end)
    end)
  end

  def get_registration(pid, plot_id) do
    Agent.get(pid, fn plots ->
      Enum.find(
        plots,
        {:not_found, "plot is unregistered"},
        fn %Plot{plot_id: test_id} -> test_id == plot_id end
      )
    end)
  end
end
