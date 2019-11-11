defmodule Changix do
  @moduledoc """
    Compile-time changelog features from static changelog files.
  """

  alias Changix.ChangelogEntry

  @default_path "/changeog"

  defmacro __using__(opts \\ []) do
    path = Keyword.get(opts, :path, @default_path)
    {:ok, entries} = entries(path)

    def_changelog_entry_count =
      quote do
        def changelog_entry_count do
          unquote(Enum.count(entries))
        end
      end

    def_changelog_entry =
      for {entry, index} <- Enum.with_index(entries) do
        quote do
          def changelog_entry(unquote(index)) do
            unquote(Macro.escape(entry))
          end
        end
      end

    [def_changelog_entry_count] ++ def_changelog_entry
  end

  defp entries(path) do
    with {:ok, raw_entries} <- read_files_content(path),
         {:ok, entries} <- parse_entries(raw_entries) do
      {:ok, entries}
    else
      _ -> :error
    end
  end

  defp read_files_content(path) do
    with {:ok, paths} <- File.ls(path),
         sorted_paths <- Enum.sort(paths, &(&1 >= &2)),
         contents <- Enum.map(sorted_paths, &File.read!("#{path}/#{&1}")),
         raw_entries <-
           Enum.map(contents, fn content ->
             content
             |> String.split("---")
             |> Enum.map(&String.trim/1)
             |> Enum.reject(&(&1 == ""))
           end) do
      {:ok, raw_entries}
    else
      _ -> :error
    end
  end

  defp parse_entries(raw_entries) do
    entries = Enum.map(raw_entries, &parse_entry/1)

    if Enum.any?(entries, &(&1 == :error)) do
      :error
    else
      {:ok, entries}
    end
  end

  defp parse_entry([header, content]) do
    entry = [content: content]

    header
    |> String.split(["\n", ":"])
    |> Enum.map(&String.trim/1)
    |> Enum.chunk_every(2)
    |> Enum.reduce_while(entry, fn
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
    |> build_entry
  end

  defp parse_entry(_), do: :error

  defp build_entry(:error), do: :error

  defp build_entry(entry) do
    if Keyword.has_key?(entry, :title) do
      struct(ChangelogEntry, entry)
    else
      kind = Keyword.get(entry, :kind)
      entry = Keyword.put(entry, :title, kind_title(kind))
      build_struct(entry)
    end
  end

  defp kind_title(title), do: title |> to_string |> String.capitalize()

  defp build_struct(entry) do
    if Keyword.has_key?(entry, :date) && Keyword.has_key?(entry, :kind) do
      struct(ChangelogEntry, entry)
    else
      :error
    end
  end
end
