defmodule Sample.CommandHandlers.Grant do
  @moduledoc """
  Command handlers for grants.
  """

  alias Sample.Aggregates.Asset
  alias Sample.Aggregates.Company
  alias Sample.Contexts.Events
  alias Sample.Contexts.FundingAccounts

  def balances(%{"payload" => payload} = params) do
    with {:ok, available} <- total_available(payload["sources"]),
         :ok <- validate_destinations(payload["destinations"]),
         {:ok, granting} <- total_granting(payload["destinations"]) do
      case Decimal.compare(granting, available) do
        :gt ->
          {:error,
           "insufficient total funds available #{available} to cover total grant #{granting}"}

        _ ->
          Events.persist_new_event!(
            %{
              type: "BalancesGranted",
              stream_identifier: UUID.uuid4(),
              payload: payload
            },
            params["author_info"]
          )
      end
    end
  end

  defp total_available(sources, acc \\ Decimal.new(0))

  defp total_available([], acc), do: {:ok, acc}

  defp total_available([%{"from_type" => "asset", "from_uuid" => asset_uuid} | rest], acc) do
    case Asset.get_state(asset_uuid) do
      {:ok, %{balance: balance}} ->
        case Decimal.compare(balance, 0) do
          :gt -> total_available(rest, Decimal.add(acc, balance))
          _ -> {:error, "insufficient funds from asset #{asset_uuid}"}
        end

      {:error, :notfound} ->
        {:error, "cannot locate asset #{asset_uuid}"}
    end
  end

  defp total_available([%{"from_type" => "company", "from_uuid" => company_uuid} | rest], acc) do
    case Company.get_state(company_uuid) do
      {:ok, %{balance: balance}} ->
        case Decimal.compare(balance, 0) do
          :gt -> total_available(rest, Decimal.add(acc, balance))
          _ -> {:error, "insufficient funds from company #{company_uuid}"}
        end

      {:error, :notfound} ->
        {:error, "cannot locate company #{company_uuid}"}
    end
  end

  defp total_available(source, _),
    do: {:error, "cannot verify funds available for #{inspect(source)}"}

  defp total_granting(destinations, acc \\ Decimal.new(0))
  defp total_granting([], acc), do: {:ok, acc}

  defp total_granting([%{"amount" => amount} | rest], acc) do
    case Decimal.parse(amount) do
      {amt, ""} -> total_granting(rest, Decimal.add(acc, amt))
      _ -> {:error, "invalid amount"}
    end
  end

  defp validate_destinations(destinations) do
    case Enum.map(destinations, &validate_destination/1) |> Enum.reject(&(&1 == :ok)) do
      [] -> :ok
      [error | _] -> error
    end
  end

  defp validate_destination(%{
         "to_company_account_uuid" => account_uuid,
         "to_company_uuid" => company_uuid
       }) do
    case FundingAccounts.find(account_uuid) do
      %{company_uuid: ^company_uuid, status: "active"} -> :ok
      _ -> {:error, "cannot find active account #{account_uuid} for company #{company_uuid}"}
    end
  end
end
