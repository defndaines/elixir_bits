defmodule Tournament do
  @header "Team                           | MP |  W |  D |  L |  P"

  @doc """
  Given `input` lines representing two teams and whether the first of them won,
  lost, or reached a draw, separated by semicolons, calculate the statistics
  for each team's number of games played, won, drawn, lost, and total points
  for the season, and return a nicely-formatted string table.

  A win earns a team 3 points, a draw earns 1 point, and a loss earns nothing.

  Order the outcome by most total points for the season, and settle ties by
  listing the teams in alphabetical order.
  """
  @spec tally(input :: list(String.t())) :: String.t()
  def tally(input) do
    Enum.reduce(input, %{}, &tally_acc/2)
    |> Enum.map(&summarize/1)
    |> Enum.sort_by(fn {_k, v} -> v.points end, :desc)
    |> Enum.map(&format/1)
    |> List.insert_at(0, @header)
    |> Enum.join("\n")
  end

  @doc """
  Increase the tally for a given team's metric by one. If no metrics have been
  recorded yet for that team or that metric, it will be set to 1.
  """
  @spec bump(records :: map(), team :: String.t(), metric :: atom()) :: map()
  defp bump(records, team, metric) do
    update_in(records, [Access.key(team, %{}), Access.key(metric, 0)], &(&1 + 1))
  end

  defp tally_acc(e, acc) do
    case String.split(e, ";") do
      [team_1, team_2, "win"] ->
        acc
        |> bump(team_1, :wins)
        |> bump(team_2, :losses)

      [team_1, team_2, "loss"] ->
        acc
        |> bump(team_1, :losses)
        |> bump(team_2, :wins)

      [team_1, team_2, "draw"] ->
        acc
        |> bump(team_1, :draws)
        |> bump(team_2, :draws)

      _ ->
        acc
    end
  end

  @doc """
  Given a map of wins, losses, and draws for a given team, calculate the total
  number of matches participated in and the overall points the team has from
  their wins and draws.
  """
  @spec summarize(entry :: {String.t(), map()}) :: {String.t(), map()}
  defp summarize({team, results}) do
    {
      team,
      results
      |> Map.put(:matches, Map.values(results) |> Enum.sum())
      |> Map.put(:points, Map.get(results, :wins, 0) * 3 + Map.get(results, :draws, 0))
    }
  end

  defp format({team, results}) do
    Enum.join(
      [
        String.pad_trailing(team, 30),
        results.matches,
        Map.get(results, :wins, 0),
        Map.get(results, :draws, 0),
        Map.get(results, :losses, 0),
        results.points
      ],
      " |  "
    )
  end
end
