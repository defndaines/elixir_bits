defmodule Sample.Helpers.ProcessManagerHelper do
  @moduledoc """
  Helper functions for process managers.
  """

  import Ecto.Query

  require Logger

  alias Sample.EventRepo
  alias Sample.ReadRepo

  @doc """
  Ensure that a process manager has a position record in the database.

  If none can be found, create a new one using the latest event ID, since process managers should
  not back-fill.
  """
  def ensure_position_exists(module) do
    projector_name = Atom.to_string(module)
    Logger.info("Checking if 'projector_positions' entry exists for: #{projector_name} ...")

    case ReadRepo.get(ReadRepo.ProjectorPosition, projector_name) do
      nil ->
        Logger.warn("Position not found. Creating new 'projector_positions' entry for #{projector_name}")

        # If a manager cannot find its last processed event id, assume that it should only work on
        # new events going forward.
        latest_event_id = EventRepo.aggregate(EventRepo.Event, :max, :id) || 0

        %ReadRepo.ProjectorPosition{projector_name: projector_name, event_id: latest_event_id}
        |> ReadRepo.insert!()

      _position ->
        Logger.info("Found 'projector_positions' entry for #{projector_name}")
        nil
    end
  end

  @doc """
  Find the latest event ID already processed by a given process manager.
  """
  def find_position(module) do
    projector_name = Atom.to_string(module)

    case ReadRepo.get(ReadRepo.ProjectorPosition, projector_name) do
      nil -> EventRepo.aggregate(EventRepo.Event, :max, :id) || 0
      position -> position.event_id
    end
  end

  @doc """
  Update the most recent event processed by a given process manager.
  """
  def update_position(module, event_id) do
    projector_name = Atom.to_string(module)
    ReadRepo.ProjectorPosition.update_last_position(projector_name, event_id)
  end

  @doc """
  Catch up with handling any events a process handler may have missed since last run.
  """
  def catch_up(module) do
    ensure_position_exists(module)
    latest_event_id = find_position(module)

    query =
      from event in EventRepo.Event,
        where: event.id > ^latest_event_id,
        order_by: [asc: event.id]

    events = EventRepo.all(query)

    Enum.each(events, fn event ->
      module.process_event(event)
      update_position(module, event.id)
    end)
  end
end
