defmodule Sample.LateFeeProcessManager do
  @moduledoc """
  Process manager for handling late fees. Late fees are triggered once per day, when the system
  cycles to the next date. Any financial products with an outstanding balance overdue at that time
  incurs a late fee.
  """

  use Sample.Manager

  require Logger

  alias Sample.Aggregates.Asset
  alias Sample.Contexts.Events
  alias Sample.Contexts.FinancialProducts

  @impl Sample.Manager
  def process_event(%{type: "SystemCycled", id: event_id, payload: %{"new_date" => cycle_date}} = event) do
    Enum.each(
      FinancialProducts.with_outstanding_balance(cycle_date),
      fn product ->
        build_late_fee_event(event_id, product)
        |> Events.persist_child_event!(event)
      end
    )

    {:ok, %{}}
  end

  @impl Sample.Manager
  def process_event(%{type: event_type}) do
    Logger.debug("#{__MODULE__} doesn't know how to process this event: #{event_type}")
    {:ok, %{}}
  end

  @doc """
  Calculate the late fee for a given financial product at a point in time determined by
  `event_id`.
  """
  @spec build_late_fee_event(pos_integer(), FinancialProducts.product_with_outstanding_balance()) :: map() | nil
  def build_late_fee_event(_event_id, %{asset_uuid: nil}) do
    Logger.warn("Pending feature.... Unable to calculate late fee for products without assets.")
    nil
  end

  def build_late_fee_event(event_id, %{
        product_uuid: product_uuid,
        asset_uuid: asset_uuid,
        daily_late_fee_rate: daily_late_fee_rate,
        late_fee_payer_role: late_fee_payer_role,
        deal_config: deal_config
      }) do
    case Asset.get_state(asset_uuid, event_id) do
      {:ok, %{value: value, sender_company_uuid: sender, receiver_company_uuid: receiver}} ->
        company_uuid =
          Enum.find_value(
            deal_config["companies"],
            fn %{"company_uuid" => company_uuid, "role" => role} ->
              role == late_fee_payer_role && Enum.member?([sender, receiver], company_uuid) &&
                company_uuid
            end
          )

        %{
          type: "LateFeeIncurred",
          stream_identifier: product_uuid,
          payload: %{
            "amount" => Decimal.mult(value, Decimal.from_float(daily_late_fee_rate)),
            "fee_payer_company_uuid" => company_uuid,
            "incurred_at" => DateTime.now!("Etc/UTC")
          }
        }

      {:error, :notfound} ->
        Logger.warn("Unable to find current value for asset '#{asset_uuid}'. Cannot calculate a late fee.")
        nil
    end
  end
end
