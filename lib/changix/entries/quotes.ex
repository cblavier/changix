defmodule Changix.Entries.Quotes do
  @moduledoc """
    `Changix.Entries.Quotes` generates functions AST related to changelog entries.
  """

  @doc """
    Returns an AST of the `changelog_entries/0` function that will return a list
    of all changelog entries, sorted by dates descending.
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
    Each changelog entry has its own `changelog_entry/1` finder (taking either a date or binary).
  """
  def quote_changelog_entry(entries) do
    for entry <- entries do
      quote do
        def changelog_entry(date = unquote(to_string(entry.date))) do
          unquote(Macro.escape(entry))
        end

        def changelog_entry(unquote(Macro.escape(entry.date))) do
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
