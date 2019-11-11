defmodule Changix.Parser do
  @moduledoc """
    Parses a single changelog file to build an `Changix.Entry`.
  """

  alias Changix.Entry

  def parse_entry(raw_entry) do
    with {:ok, [raw_header | content]} <- split_header_and_content(raw_entry),
         {:ok, header} <- parse_header(raw_header),
         {:ok, entry} <- build_entry(header, content) do
      entry
    else
      _ -> :error
    end
  end

  defp split_header_and_content(raw_entry) do
    splited_entry =
      raw_entry
      |> String.split("---")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    case splited_entry do
      [header | content] -> {:ok, [header | content]}
      _ -> {:error, :invalid_entry_structure}
    end
  end

  defp parse_header(raw_header) do
    header =
      raw_header
      |> String.split(["\n", ":"])
      |> Enum.map(&String.trim/1)
      |> Enum.chunk_every(2)
      |> Enum.reduce_while([], fn
        ["date", value], acc ->
          case Date.from_iso8601(value) do
            {:ok, date} -> {:cont, Keyword.put(acc, :date, date)}
            _ -> {:halt, :error}
          end

        [key, value], acc ->
          {:cont, Keyword.put(acc, String.to_atom(key), String.to_atom(value))}

        _, _ ->
          {:halt, :error}
      end)

    {:ok, header}
  end

  defp build_entry(header, content) do
    if Keyword.has_key?(header, :title) do
      build_and_validate_struct(header, content)
    else
      kind = Keyword.get(header, :kind)
      header = Keyword.put(header, :title, kind_title(kind))
      build_and_validate_struct(header, content)
    end
  end

  defp kind_title(title), do: title |> to_string |> String.capitalize()

  defp build_and_validate_struct(header, content) do
    if Keyword.has_key?(header, :date) && Keyword.has_key?(header, :kind) &&
         Keyword.has_key?(header, :title) do
      entry = Keyword.put(header, :content, content)
      {:ok, struct(Entry, entry)}
    else
      {:error, :missing_entry_header_fields}
    end
  end
end
