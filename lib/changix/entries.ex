defmodule Changix.Entries do
  @moduledoc """
    `Changix.Entries` is dedicated to changelog retrieval and YAML header parsing.
  """
  alias Changix.{HTML, Parser}

  @doc """
    Given a changelog folder path, retrieves a list of changelog entries, parses their
    YAML header and returns them as `Changix.Entry`
  """
  def render_changelogs(path, opts) do
    with {:ok, file_names_with_raw_entries} <- read_files_content(path),
         {:ok, entries} <- parse_entries(file_names_with_raw_entries),
         {:ok, rendered_entries} <- render_entries_content(entries, opts),
         sorted_entries <-
           Enum.sort(
             rendered_entries,
             &(NaiveDateTime.to_erl(&1.changed_at) >= NaiveDateTime.to_erl(&2.changed_at))
           ) do
      {:ok, sorted_entries}
    else
      {:error, reason} -> raise reason
      _ -> raise "Could not parse changelog"
    end
  end

  defp read_files_content(folder_path) do
    with {:ok, file_names} <- File.ls(folder_path),
         sorted_file_names <- Enum.sort(file_names, &(&1 >= &2)),
         paths_with_raw_entries <-
           Enum.map(sorted_file_names, fn file_name ->
             changelog_path = "#{folder_path}/#{file_name}"
             {changelog_path, File.read!(changelog_path)}
           end) do
      {:ok, paths_with_raw_entries}
    else
      {:error, :enoent} -> {:error, "Unknow changelog path #{folder_path}"}
      {:error, reason} -> {:error, reason}
      _ -> :error
    end
  end

  defp parse_entries(paths_with_raw_entries) do
    entries =
      Enum.reduce_while(paths_with_raw_entries, [], fn {path, raw_entry}, acc ->
        case Parser.parse_entry(raw_entry, path) do
          {:ok, entry} ->
            {:cont, acc ++ [entry]}

          {:error, reason} when is_binary(reason) ->
            {:halt, {:error, "#{reason} for file #{path}"}}

          _ ->
            {:halt, {:error, "Unknown reason for file #{path}"}}
        end
      end)

    case entries do
      {:error, reason} -> {:error, reason}
      _ -> {:ok, entries}
    end
  end

  defp render_entries_content(entries, opts) do
    rendered_entries =
      Enum.reduce_while(entries, [], fn entry, acc ->
        with {:ok, full_html} <- HTML.render_content(entry, Keyword.put(opts, :summary, false)),
             {:ok, summary_html} <- HTML.render_content(entry, Keyword.put(opts, :summary, true)) do
          entry = Map.merge(entry, %{full_html: full_html, summary_html: summary_html})
          {:cont, acc ++ [entry]}
        else
          {:error, reason} -> {:error, reason}
          _ -> {:error, "Unknow error while rendering entries"}
        end
      end)

    {:ok, rendered_entries}
  end
end
