defmodule Sample.DailyCycler do
  @moduledoc """
  Cron server for ensuring that the business date has been cycled. It should ensure that the
  `SystemCycled` event gets created exactly once per day.
  """

  use GenServer

  require Logger

  alias Sample.Contexts.Events
  alias Sample.EventRepo.Event
  alias Sample.Helpers.DateTimeHelper

  # Run once every hour.
  @period 60 * 60 * 1000

  @stream_identifier "sample"

  @typep state() :: %{optional(:last_cycle) => Date.t()}

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  @impl GenServer
  def init(state) do
    schedule_cycle()
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:cycle, state) do
    new_state = cycle_system(state)
    schedule_cycle()
    {:noreply, new_state}
  end

  @doc """
  Cycle the system. If the state or event store indicates we've already cycled for today, do
  nothing. Otherwise, create a new `SystemCycled` event for today.
  """
  @spec cycle_system(state()) :: state()
  def cycle_system(state) do
    last_cycle =
      case Map.get(state, :last_cycle) do
        nil -> last_cycle_from_stream()
        date -> date
      end

    date_today = DateTimeHelper.today_in_la()

    if date_today == last_cycle do
      Logger.debug("#{__MODULE__} already cycled for #{date_today}")
      state
    else
      Logger.info("#{__MODULE__} cycling for #{date_today}")

      Events.persist_new_event!(
        %{
          type: "SystemCycled",
          stream_identifier: @stream_identifier,
          payload: %{"new_date" => date_today}
        },
        %{"id" => "Sample.DailyCycler"}
      )

      %{last_cycle: date_today}
    end
  end

  defp last_cycle_from_stream() do
    case Events.find_latest_by_stream_identifier(@stream_identifier) do
      %Event{payload: %{"new_date" => last_cycle}} ->
        case Date.from_iso8601(last_cycle) do
          {:ok, valid_date} -> valid_date
          {:error, _} -> nil
        end

      _ ->
        nil
    end
  end

  defp schedule_cycle(), do: Process.send_after(self(), :cycle, @period)
end
