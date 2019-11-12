defmodule Changix.Entries.Quotes do
  @moduledoc """
    `Changix.Entries.Quotes` generates functions AST related to changelog entries.
  """

  @doc """
    Returns an AST of the `changelog_entries/0` function that will return a list
    of all changelog entries, sorted by datetimes descending.
  """
  def quote_changelog_entries(entries) do
    quote do
      def changelog_entries do
        unquote(Macro.escape(entries))
      end
    end
  end

  @doc """
    Returns a list of function ASTs.
    Each changelog entry has its own `changelog_entry/1` finder (taking either a datetime or binary).
  """
  def quote_changelog_entry(entries) do
    for entry <- entries do
      quote do
        def changelog_entry(datetime = unquote(NaiveDateTime.to_iso8601(entry.datetime))) do
          unquote(Macro.escape(entry))
        end

        def changelog_entry(unquote(Macro.escape(entry.datetime))) do
          unquote(Macro.escape(entry))
        end
      end
    end
  end

  @doc """
    Default nil `changelog_entry/1` finder.
  """
  def quote_unknown_changelog_entry do
    quote do
      def changelog_entry(_), do: nil
    end
  end
end
