defmodule Changix.Entries do
  @moduledoc """
    `Changix.Entries` is dedicated to changelog retrieval and YAML header parsing.
  """
  alias Changix.Entries.Parser

  @doc """
    Given a changelog folder path, retrieves a list of changelog entries, parses their
    YAML header and returns them as `Changix.Entries.Entry`
  """
  def list(path) do
    with {:ok, file_names_with_raw_entries} <- read_files_content(path),
         {:ok, entries} <- parse_entries(file_names_with_raw_entries),
         sorted_entries <-
           Enum.sort(
             entries,
             &(NaiveDateTime.to_erl(&1.datetime) >= NaiveDateTime.to_erl(&2.datetime))
           ) do
      {:ok, sorted_entries}
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
      {:error, :enoent} -> {:error, "Unknow changelog path #{path}"}
      {:error, reason} -> {:error, reason}
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
