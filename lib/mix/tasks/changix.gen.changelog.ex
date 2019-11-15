defmodule Mix.Tasks.Changix.Gen.Changelog do
  @moduledoc """
  Generates a new changelog entry.

  ## Command line options:

    - `--folder` or `-f`. Optional, defaults to `/changelog`.
    - `--kind` or `-k`. Optional, defaults to nil.
    - `title`. Mandatory.

  ## Examples:

  ```
    mix changix.gen.changelog My new feature
    mix changix.gen.changelog --folder /priv/changelog --kind bugfix Fixed login
    mix changix.gen.changelog -f /priv/changelog -k bugfix Fixed login
  ```
  """

  alias Mix.Generator
  use Mix.Task

  @shortdoc "Generates a new changelog entry"
  @template "priv/templates/changelog.md.eex"
  @default_folder "changelog"

  def run(args) do
    {switches, title_parts, _} =
      OptionParser.parse(args,
        switches: [folder: :string, kind: :string],
        aliases: [f: :folder, k: :kind]
      )

    if blank?(title_parts) do
      Mix.raise("expected mix changix.gen.changelog to take the changelog title")
    end

    kind = Keyword.get(switches, :kind, "")
    folder = Keyword.get(switches, :folder, @default_folder)
    folder = Path.join(File.cwd!(), folder)
    changed_at = local_now()
    quiet = Mix.env() == :test

    Generator.create_directory(folder, quiet: quiet)

    Generator.copy_template(
      Path.join(File.cwd!(), @template),
      Path.join(folder, file_name(changed_at, title_parts)),
      [
        title: Enum.join(title_parts, " "),
        changed_at: NaiveDateTime.to_iso8601(changed_at),
        kind: kind
      ],
      quiet: quiet
    )
  end

  defp local_now do
    {{year, month, day}, {hour, minute, second}} = :erlang.localtime()
    {:ok, ndt} = NaiveDateTime.new(year, month, day, hour, minute, second)
    ndt
  end

  defp file_name(changed_at, title_parts) do
    file_title = title_parts |> Enum.map(&String.downcase/1) |> Enum.join("_")
    changed_at = changed_at |> NaiveDateTime.to_string() |> String.replace(["-", " ", ":"], "")
    "#{changed_at}-#{file_title}.md"
  end

  defp blank?([]), do: true
  defp blank?(title_parts) when length(title_parts) > 1, do: false

  defp blank?([title_part]) do
    String.trim(title_part) == ""
  end
end
