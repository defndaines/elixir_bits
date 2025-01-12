defmodule LogParser do
  def valid_line?(line), do: line =~ ~r/^\[(DEBUG|INFO|WARNING|ERROR)\]/

  def split_line(line), do: Regex.split(~r/<[~*=-]*>/, line)

  def remove_artifacts(line), do: Regex.replace(~r/end-of-line\d+/i, line, "")

  def tag_with_user_name(line) do
    case Regex.run(~r/User\s+(\S+)/, line, capture: :all_but_first) do
      nil -> line
      [user] -> "[USER] #{user} #{line}"
    end
  end
end
