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

  defp tally_acc(e, acc) do
    case String.split(e, ";") do
      [team_1, team_2, "win"] ->
        acc
        |> update_in([Access.key(team_1, %{}), Access.key(:wins, 0)], &(&1 + 1))
        |> update_in([Access.key(team_2, %{}), Access.key(:losses, 0)], &(&1 + 1))
      [team_1, team_2, "loss"] ->
        acc
        |> update_in([Access.key(team_1, %{}), Access.key(:losses, 0)], &(&1 + 1))
        |> update_in([Access.key(team_2, %{}), Access.key(:wins, 0)], &(&1 + 1))
      [team_1, team_2, "draw"] ->
        acc
        |> update_in([Access.key(team_1, %{}), Access.key(:draws, 0)], &(&1 + 1))
        |> update_in([Access.key(team_2, %{}), Access.key(:draws, 0)], &(&1 + 1))
      _ -> acc
    end
  end

  defp summarize({team, results}) do
    {
      team,
      results
      |> Map.put(:matches, Map.values(results) |> Enum.sum)
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
      " |  ")
  end
end
