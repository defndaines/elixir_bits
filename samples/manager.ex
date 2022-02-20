defmodule Sample.MissedEventError do
  defexception message: "received an event out of order"
end

defmodule Sample.Manager do
  @moduledoc """
  'Parent' module for Process Managers to use to ensure a common set of functionality. This
  includes ensuring that events are handled in order, and if an event comes in out of sequence,
  we recover from it. (Out of sequence events typically happen because of DB transactions
  upstream.)
  """

  alias Sample.EventRepo.Event

  @type result :: {:ok, map()}

  @callback process_event(Event.t()) :: result()

  defmacro __using__(_) do
    quote do
      @behaviour Sample.Manager

      use GenServer

      require Logger

      alias Sample.Helpers.ProcessManagerHelper

      def start_link(_) do
        Logger.info("#{__MODULE__} Starting ...")
        GenServer.start_link(__MODULE__, 0, name: __MODULE__)
      end

      @impl GenServer
      def init(_) do
        Logger.info("#{__MODULE__} Initializing ...")
        {:ok, nil, {:continue, :init_and_catch_up}}
      end

      @doc """
      Handle any potentially slow initialization processes. Also catch up the process manager to
      the latest event to account for any events missed since the manager last ran.
      This method is guaranteed to run before any `handle_info/2` invocations.
      """
      @impl GenServer
      def handle_continue(:init_and_catch_up, _) do
        # Since restarting could be the result of a crash due to out-of-order events, add in some
        # delay to give events time to appear.
        [
          hydration_delay: hydration_delay,
          hydration_delay_entropy: hydration_delay_entropy
        ] = Application.get_env(:sample, :projector_options)

        Process.sleep(hydration_delay + Enum.random(0..hydration_delay_entropy))

        ProcessManagerHelper.catch_up(__MODULE__)
        last_processed_id = ProcessManagerHelper.find_position(__MODULE__)
        Logger.info("#{__MODULE__} Initialization complete and ready to receive new events.")

        {:noreply, %{last_processed_id: last_processed_id}}
      end

      @doc """
      Handle published events by delegating the processing to `process_event/1`.
      """
      @impl GenServer
      def handle_info(
            %{stream_identifier: _, type: event_type, payload: _, id: event_id} = event,
            %{last_processed_id: last_processed_id} = state
          )
          when event_id > last_processed_id do
        Logger.info("#{__MODULE__} received published event: #{event_type} #{event_id}")

        ensure_sequentiality_of_events!(event_id, last_processed_id)

        {:ok, new_state} = process_event(event)
        ProcessManagerHelper.update_position(__MODULE__, event_id)

        {:noreply, Map.merge(%{state | last_processed_id: event_id}, new_state)}
      end

      @doc """
      Log events that have already been processed.
      """
      @impl GenServer
      def handle_info(
            %{stream_identifier: _, type: _, payload: _, id: _} = event,
            %{last_processed_id: _} = state
          ) do
        Logger.info(
          "#{__MODULE__} received an event that was already processed: #{inspect(event)}"
        )

        {:noreply, state}
      end

      @doc """
      Handle messages that are not event store events (i.e., messages that don't have a
      `stream_identifier`, `type`, and `payload`).
      """
      @impl GenServer
      def handle_info(%{id: event_id} = message, state) do
        Logger.info(
          "#{__MODULE__} received a message that it does not handle: #{inspect(message)}"
        )

        # We don't guarantee sequentiality here.
        {:noreply, Map.merge(state, %{last_processed_id: event_id})}
      end

      @impl GenServer
      def handle_call(:last_processed_id, _, %{last_processed_id: last_processed_id} = state) do
        # Exposed for testing.
        {:reply, last_processed_id, state}
      end

      defp ensure_sequentiality_of_events!(event_id, last_processed_id) do
        if event_id != last_processed_id + 1 do
          raise Sample.MissedEventError,
            message:
              "#{__MODULE__} received event #{event_id} but last processed event #{last_processed_id}"
        end
      end
    end
  end
end
