defmodule Changix do
  @moduledoc """
    Compile-time changelog features from static changelog files.
    Including the module will provide with following functions:

    - `changelog_entries/0`, which return all changelog entries ordered by desc date
    - `changelog_entry/1`, which takes a date and returns a single entry
  """

  alias Changix.Entries
  alias Changix.Quotes

  @default_path "/changeog"

  defmacro __using__(opts \\ []) do
    path = Keyword.get(opts, :path, @default_path)
    {:ok, entries} = Entries.list(path)

    flatten_defs([
      quote(do: import(Changix.HTML)),
      Quotes.quote_changelog_entries(entries),
      Quotes.quote_changelog_entry(entries),
      Quotes.quote_unknown_changelog_entry()
    ])
  end

  defp flatten_defs(defs) do
    Enum.flat_map(defs, fn
      defs when is_list(defs) -> defs
      single_def -> [single_def]
    end)
  end
end
