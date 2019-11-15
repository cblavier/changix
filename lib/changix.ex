defmodule Changix do
  @moduledoc """
    Compile-time changelog features from static changelog files.
    Including the module will provide with following functions:

    - `changelog_entries/0`, which return all changelog entries ordered by desc date
    - `changelog_entry/1`, which takes a date and returns a single entry

  `include Changix` can take following options:
    - `path`: changelog folder. Defaults to "changelog"
    - `renderer`: function that takes 2 parameters(markdown, changelog_path) and should
      return `{:ok, html}` or `{:error, reason}`. Defaults to Earmark implementation.
    - `read_more_class`: css class used to render the read more link. Defaults to `read_more`.
    - `read_more_label`: label used to used to render the read more link. Defaults to "Read more".
  """

  alias Changix.Entries

  @default_path "changelog"

  defmacro __using__(opts \\ []) do
    path = Keyword.get(opts, :path, @default_path)

    quote bind_quoted: [opts: opts, path: path] do
      {:ok, entries} = Entries.render_changelogs(path, opts)

      def changelog_entries do
        unquote(Macro.escape(entries))
      end

      for entry <- entries do
        @external_resource entry.path

        def changelog_entry(unquote(NaiveDateTime.to_iso8601(entry.changed_at))) do
          unquote(Macro.escape(entry))
        end

        def changelog_entry(unquote(Macro.escape(entry.changed_at))) do
          unquote(Macro.escape(entry))
        end
      end

      def changelog_entry(_), do: nil
    end
  end
end
