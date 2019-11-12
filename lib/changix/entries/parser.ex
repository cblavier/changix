defmodule Changix.Entries.Parser do
  @moduledoc """
    Parses a single changelog file to build an `Changix.Entry`.
  """

  alias Changix.Entries.Entry

  @doc """
    Parses a markdown entry with YAML front matter header.

    Returns `{:ok, %Changix.Entry{}}` or `{:error, reason}`.
  """
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
      |> String.split(["\n"])
      |> Enum.map(fn header ->
        header
        |> String.split(":", parts: 2)
        |> Enum.map(&String.trim/1)
      end)
      |> Enum.reduce_while([], fn
        ["datetime", value], acc ->
          case NaiveDateTime.from_iso8601(value) do
            {:ok, datetime} -> {:cont, Keyword.put(acc, :datetime, datetime)}
            _ -> {:halt, :invalid_datetime}
          end

        [key, value], acc ->
          {:cont, Keyword.put(acc, String.to_atom(key), String.to_atom(value))}

        _, _ ->
          {:halt, :error}
      end)

    case header do
      :invalid_datetime -> {:error, "Invalid datetime in header"}
      :error -> {:error, "Unknow error while parsing header"}
      _ -> {:ok, header}
    end
  end

  defp build_entry(header, content) do
    if Keyword.has_key?(header, :title) do
      build_and_validate_struct(header, content)
    else
      kind = Keyword.get(header, :kind)
      header = Keyword.put(header, :kind_label, humanize(kind))
      build_and_validate_struct(header, content)
    end
  end

  defp humanize(atom) when is_atom(atom), do: humanize(Atom.to_string(atom))

  defp humanize(bin) when is_binary(bin) do
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
