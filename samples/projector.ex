defmodule Sample.MissedEventError do
  defexception message: "received event out of sequence"
end

defmodule Sample.Projector do
  @moduledoc """
  Behaviour module for Projectors which ensures a common set of functionality. This includes
  ensuring that events are handled in order, and if an event comes in out of sequence, we recover
  from it. (Out of sequence events typically happen because of DB transactions upstream.)

  By default, projectors are autonomous in that initialization happens asynchronously, and that
  all implementations are expected to implement autonomous projectors, i.e., they do not reach out
  to other modules for state but instead rely solely on the event stream to determine state.
  Typically this will mean that only this projector can read from and write to the repository it
  owns (either directly or through helper functions).

  If the user needs a non-autonomous projector which is order-dependent while hydrating, they
  should pass the `:dependent_hydration` option. In these cases, initialization must happen
  synchronously because it relies upon the state of other modules and repositories besides the
  event stream it monitors and repositories it owns.
  """

  alias Sample.EventRepo.Event

  @type result :: {:error, String.t()} | {:ok, nil}

  @callback process_event(Event.t()) :: result

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Sample.Projector

      use GenServer

      require Logger

      alias Sample.Helpers.ProjectorHelper

      def start_link(_) do
        Logger.info("#{__MODULE__} Starting...")
        GenServer.start_link(__MODULE__, 0, name: __MODULE__)
      end

      @impl GenServer
      if opts[:dependent_hydration] do
        def init(_) do
          Logger.info("#{__MODULE__} Initializing ...")

          [
            hydration_delay: hydration_delay,
            hydration_delay_entropy: hydration_delay_entropy
          ] = Application.get_env(:sample, :projector_options)

          Process.sleep(hydration_delay + Enum.random(0..hydration_delay_entropy))
          ProjectorHelper.check_position_and_rehydrate(__MODULE__)
          Logger.info("#{__MODULE__} Ready to project new events ...")
          {:ok, %{last_processed_id: ProjectorHelper.find_projector_position(__MODULE__)}}
        end
      else
        def init(_) do
          Logger.info("#{__MODULE__} Initializing ...")
          {:ok, nil, {:continue, :init_and_rehydrate}}
        end
      end

      @doc """
      Handle potentially slow initialization processes. This includes rehydration of any missed
      events since the last time a given projector ran.

      This function is guaranteed to run before any `handle_info/1` invocations.
      """
      @impl GenServer
      def handle_continue(:init_and_rehydrate, _state) do
        # Since restarting could be the result of a crash due to out-of-order events, add in some
        # delay to give events time to appear.
        [
          hydration_delay: hydration_delay,
          hydration_delay_entropy: hydration_delay_entropy
        ] = Application.get_env(:sample, :projector_options)

        Process.sleep(hydration_delay + Enum.random(0..hydration_delay_entropy))

        ProjectorHelper.check_position_and_rehydrate(__MODULE__)
        last_processed_id = ProjectorHelper.find_projector_position(__MODULE__)
        Logger.info("#{__MODULE__} Ready to project new events ...")

        {:noreply, %{last_processed_id: last_processed_id}}
      end

      @doc """
      Handle published events by delegating the processing of each event to `process_event/1`.
      """
      @impl GenServer
      def handle_info(
            %{stream_identifier: _, type: event_type, payload: _, id: received_event_id} =
              message,
            %{last_processed_id: last_processed_id}
          )
          when received_event_id > last_processed_id do
        Logger.info("#{__MODULE__} received published event: #{event_type} #{received_event_id}")

        # check received event id against last processed event id
        ensure_sequentiality_of_events!(received_event_id, last_processed_id)

        case process_event(message) do
          {:ok, _} ->
            ProjectorHelper.update_projector_position(__MODULE__, received_event_id)
        end

        {:noreply, %{last_processed_id: received_event_id}}
      end

      @doc """
      Log events that have already been processed (e.g., during hydration when a projector restart
      occurs).
      """
      @impl GenServer
      def handle_info(
            %{stream_identifier: _, type: _, payload: _, id: received_event_id} = message,
            %{last_processed_id: last_processed_id} = state
          ) do
        Logger.info(
          "#{__MODULE__} received a event that was already processed: #{inspect(message)}"
        )

        {:noreply, state}
      end

      @doc """
      Handle messages that are not event store events (i.e., messages that don't have a
      `stream_identifier`, `type`, and `payload`).
      """
      @impl GenServer
      def handle_info(%{id: received_event_id} = message, state) do
        Logger.info(
          "#{__MODULE__} received a message that it does not handle: #{inspect(message)}"
        )

        {:noreply, %{last_processed_id: received_event_id}}
      end

      defp ensure_sequentiality_of_events!(received_event_id, last_processed_id) do
        if received_event_id != last_processed_id + 1 do
          raise Sample.MissedEventError,
            message:
              "Error: #{__MODULE__} received event #{received_event_id} with last processed event #{last_processed_id}"
        end
      end
    end
  end
end
