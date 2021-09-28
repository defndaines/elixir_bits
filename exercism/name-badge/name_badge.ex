defmodule NameBadge do
  def print(id, name, department) do
    [
      if(id, do: "[#{id}]"),
      name,
      if(department, do: String.upcase(department), else: "OWNER")
    ]
    |> Enum.filter(& &1)
    |> Enum.join(" - ")
  end
end
