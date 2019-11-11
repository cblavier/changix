defmodule Changix do
  @moduledoc """
    Compile-time changelog features from static changelog files.
    Provides following functions:

    - changelog_entries/0, which return all changelog entries ordered by desc date
    - changelog_entry/1, which takes a date and returns a single entry
  """

  alias Changix.Parser

  @default_path "/changeog"

  defmacro __using__(opts \\ []) do
    path = Keyword.get(opts, :path, @default_path)
    {:ok, entries} = entries(path)

    def_changelog_entries =
      quote do
        def changelog_entries do
          unquote(Macro.escape(entries))
        end
      end

    def_changelog_entry =
      for entry <- entries do
        quote do
          def changelog_entry(unquote(Macro.escape(entry.date))) do
            unquote(Macro.escape(entry))
          end
        end
      end

    def_unknown_changelog_entry =
      quote do
        def changelog_entry(_), do: nil
      end

    [def_changelog_entries] ++ def_changelog_entry ++ [def_unknown_changelog_entry]
  end

  defp entries(path) do
    with {:ok, file_names_with_raw_entries} <- read_files_content(path),
         {:ok, entries} <- parse_entries(file_names_with_raw_entries) do
      {:ok, entries}
    else
      {:error, reason} -> raise reason
      _ -> raise "Could not parse changelog"
    end
  end

  defp read_files_content(path) do
    with {:ok, paths} <- File.ls(path),
         sorted_paths <- Enum.sort(paths, &(&1 >= &2)),
         file_names_with_raw_entries <- Enum.map(sorted_paths, &{&1, File.read!("#{path}/#{&1}")}) do
      {:ok, file_names_with_raw_entries}
    else
      _ -> :error
    end
  end

  defp parse_entries(file_names_with_raw_entries) do
    entries =
      Enum.reduce_while(file_names_with_raw_entries, [], fn {file_name, raw_entry}, acc ->
        case Parser.parse_entry(raw_entry) do
          {:ok, entry} ->
            {:cont, acc ++ [entry]}

          {:error, reason} when is_binary(reason) ->
            {:halt, {:error, "#{reason} for file #{file_name}"}}

          _ ->
            {:halt, {:error, "Unknown reason for file #{file_name}"}}
        end
      end)

    case entries do
      {:error, reason} -> {:error, reason}
      _ -> {:ok, entries}
    end
  end
end
