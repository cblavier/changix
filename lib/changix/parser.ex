defmodule Changix.Parser do
  @moduledoc """
    Parses a single changelog file to build an `Changix.Entry`.
  """

  alias Changix.Entry

  def parse_entry(raw_entry) do
    with {:ok, [raw_header | content]} <- split_header_and_content(raw_entry),
         {:ok, header} <- parse_header(raw_header),
         {:ok, entry} <- build_entry(header, content) do
      {:ok, entry}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, :unknow_reason}
    end
  end

  defp split_header_and_content(raw_entry) do
    splited_entry =
      raw_entry
      |> String.split("---")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    if length(splited_entry) == 2 do
      {:ok, splited_entry}
    else
      {:error, "Invalid entry structure"}
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
            _ -> {:halt, :invalid_date}
          end

        [key, value], acc ->
          {:cont, Keyword.put(acc, String.to_atom(key), String.to_atom(value))}

        _, _ ->
          {:halt, :error}
      end)

    case header do
      :invalid_date -> {:error, "Invalid date in header"}
      :error -> {:error, "Unknow error while parsing header"}
      _ -> {:ok, header}
    end
  end

  defp build_entry(header, content) do
    if Keyword.has_key?(header, :title) do
      build_and_validate_struct(header, content)
    else
      kind = Keyword.get(header, :kind)
      header = Keyword.put(header, :title, humanize(kind))
      build_and_validate_struct(header, content)
    end
  end

  def humanize(atom) when is_atom(atom), do: humanize(Atom.to_string(atom))

  def humanize(bin) when is_binary(bin) do
    bin =
      if String.ends_with?(bin, "_id") do
        binary_part(bin, 0, byte_size(bin) - 3)
      else
        bin
      end

    bin |> String.replace("_", " ") |> String.capitalize()
  end

  defp build_and_validate_struct(header, content) do
    if Entry.required_headers() |> Enum.all?(&Keyword.has_key?(header, &1)) do
      entry = Keyword.put(header, :content, content)
      {:ok, struct(Entry, entry)}
    else
      {:error, "Missing required header fields"}
    end
  end
end
