defmodule Markdown do
  @doc """
    Parses a given string with Markdown syntax and returns the associated HTML for that string.

    ## Examples

    iex> Markdown.parse("This is a paragraph")
    "<p>This is a paragraph</p>"

    iex> Markdown.parse("#Header!\n* __Bold Item__\n* _Italic Item_")
    "<h1>Header!</h1><ul><li><em>Bold Item</em></li><li><i>Italic Item</i></li></ul>"
  """
  @spec parse(String.t()) :: String.t()
  def parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(&process/1)
    |> Enum.join()
    |> ensure_ul()
  end

  defp process(line = <<?#, _::binary>>), do: parse_header(line)
  defp process(line = <<?*, _::binary>>), do: parse_list_item(line)
  defp process(line), do: parse_paragraph(line)

  defp parse_header(line) do
    [h | text] = String.split(line)
    level = String.length(h)
    "<h#{level}>#{Enum.join(text, " ")}</h#{level}>"
  end

  defp parse_list_item(line) do
    "<li>#{parse_highlight_tags(String.trim_leading(line, "* "))}</li>"
  end

  defp parse_paragraph(line) do
    "<p>#{parse_highlight_tags(line)}</p>"
  end

  defp parse_highlight_tags(line) do
    line
    |> String.split()
    |> Enum.map(&parse_strong_and_em/1)
    |> Enum.join(" ")
  end

  defp parse_strong_and_em(word) do
    word
    |> String.replace(~r/^__/, "<strong>")
    |> String.replace(~r/__$/, "</strong>")
    |> String.replace(~r/^_/, "<em>")
    |> String.replace(~r/_$/, "</em>")
  end

  defp ensure_ul(text) do
    text
    |> String.replace("<li>", "<ul><li>", global: false)
    |> String.replace_suffix("</li>", "</li></ul>")
  end
end
