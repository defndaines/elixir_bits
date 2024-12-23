defmodule Sample.Aggregates.Membership do
  @moduledoc """
  An aggregate for tracking companies' Membership details.
  """

  use GenServer, restart: :temporary

  import Ecto.Query, warn: false

  alias Sample.EventRepo

  @type details ::
          %{
            :activated => boolean(),
            :deal => String.t(),
            :rating_tier => String.t()
          }
          | %{}

  ###########
  ### API ###
  ###########

  @doc """
  Lookup membership details for a given company.
  """
  @spec lookup(company_uuid :: String.t()) :: details
  def lookup(company_uuid) do
    case :ets.lookup(:membership, company_uuid) do
      [{^company_uuid, state}] -> state
      [] -> %{}
    end
  end

  ########################
  ### Event Processors ###
  ########################

  defp process_event(%{
         type: type,
         stream_identifier: deal_uuid,
         payload: %{
           "product_line_id" => 4,
           "companies" => [%{"company_uuid" => company_uuid}],
           "rating_tier" => tier
         }
       })
       when type in ["DealCreated", "DealUpdated"] do
    true =
      :ets.insert(
        :membership,
        {company_uuid, %{rating_tier: tier, activated: false, deal: deal_uuid}}
      )
  end

  defp process_event(%{type: "DealActivated", stream_identifier: deal_uuid}) do
    # Only activate the deal if it is one we've tracked (i.e., a membership deal)
    case :ets.match_object(:membership, {:_, %{deal: deal_uuid}}) do
      [{company_uuid, deal}] ->
        :ets.insert(:membership, {company_uuid, %{deal | activated: true}})

      [] ->
        :ignored
    end
  end

  defp process_event(%{type: "DealDeleted", stream_identifier: deal_uuid}) do
    # Only delete the deal if it is one we've tracked (i.e., a membership deal)
    [[company_uuid]] = :ets.match(:membership, {:"$1", %{deal: deal_uuid}})

    if lookup(company_uuid) != %{} do
      :ets.delete(:membership, company_uuid)
    end
  end

  defp process_event(_), do: :ignored

  defp hydrate() do
    EventRepo.all(
      from(e in EventRepo.Event,
        where: like(e.type, ^"Deal%"),
        order_by: [asc: :id]
      )
    )
    |> Enum.each(&process_event/1)
  end

  ##############
  ### SERVER ###
  ##############

  def start_link({:membership, _}) do
    GenServer.start_link(__MODULE__, :membership, name: :membership)
  end

  def send_event(pid, event), do: Sample.Aggregates.Process.send_event(pid, event)

  @impl GenServer
  def init(_) do
    Registry.register(
      Sample.Aggregates.SubscriptionRegistry,
      :_,
      {__MODULE__, :_}
    )

    table = :ets.new(:membership, [:named_table])
    hydrate()

    {:ok, table}
  end

  @impl GenServer
  def handle_call(%{action: :process_event, event: event}, _from, state) do
    process_event(event)
    {:reply, :ok, state}
  end

  @doc """
  Catchall for calls that don't match our specs
  """
  @impl GenServer
  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end
end
