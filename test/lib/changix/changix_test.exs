defmodule ChangixTest do
  use ExUnit.Case

  defmodule ChangixStub do
    use Changix, path: "test/fixtures/changelog"
  end

  test "changelog_entries" do
    entries = ChangixStub.changelog_entries()
    assert length(entries) == 2
  end

  test "changelog_entries returns entries in correct order" do
    entries = ChangixStub.changelog_entries()
    first = Enum.at(entries, 0)
    last = Enum.at(entries, 1)
    assert Date.to_erl(first.changed_at) >= Date.to_erl(last.changed_at)
  end

  test "changelog_entries with bad path cannot compile" do
    assert_raise RuntimeError, "Unknow changelog path test/fixtures/changelog_unknown_path", fn ->
      compile_quoted(
        quote do
          defmodule ChangixUnknownPath do
            use Changix, path: "test/fixtures/changelog_unknown_path"
          end
        end
      )
    end
  end

  test "changelog_entry" do
    entry = ChangixStub.changelog_entry(~N[2019-11-10T17:10:05])

    refute is_nil(entry.content)
    assert entry.changed_at == ~N[2019-11-10T17:10:05]
    assert entry.kind == :bugfix
    assert entry.kind_label == "Bugfix"
  end

  test "changelog_entry markdown rendering with summary" do
    entry = ChangixStub.changelog_entry(~N[2019-11-10T17:10:05])
    assert String.starts_with?(entry.full_html, "<h1>Bugfix</h1>")
    assert String.length(entry.full_html) > String.length(entry.summary_html)
  end

  test "changelog_entry markdown rendering without summary" do
    entry = ChangixStub.changelog_entry(~N[2019-11-10T18:12:01])
    assert String.starts_with?(entry.full_html, "<h1>New feature</h1>")
    assert String.length(entry.full_html) == String.length(entry.summary_html)
  end

  test "changelog_entry markdown rendering with custom renderer" do
    [{mod, _}] =
      Code.compile_quoted(
        quote do
          defmodule ChangixCustomRenderer do
            use Changix,
              path: "test/fixtures/changelog",
              renderer: fn markdown, _path -> {:ok, String.length(markdown)} end
          end
        end
      )

    entry = mod.changelog_entry(~N[2019-11-10T17:10:05])
    assert entry.full_html == 914
    assert entry.summary_html == 498
  end

  test "changelog_entry markdown rendering with custom read more attributes" do
    [{mod, _}] =
      Code.compile_quoted(
        quote do
          defmodule ChangixCustomReadMore do
            use Changix,
              path: "test/fixtures/changelog",
              read_more_class: "foo",
              read_more_label: "Bar ..."
          end
        end
      )

    entry = mod.changelog_entry(~N[2019-11-10T17:10:05])
    assert String.contains?(entry.summary_html, "<div class='foo'>Bar ...</div>")
  end

  test "changelog_entry with binary dates" do
    assert ChangixStub.changelog_entry("2019-11-10T17:10:05").changed_at ==
             ~N[2019-11-10T17:10:05]

    assert ChangixStub.changelog_entry("2019-11-10T18:12:01").changed_at ==
             ~N[2019-11-10T18:12:01]
  end

  test "changelog_entry with unknown entry" do
    assert is_nil(ChangixStub.changelog_entry(:foo))
  end

  test "changelog_entry with bad date cannot compile" do
    assert_error(
      "Invalid changed_at in header for file test/fixtures/changelog_bad_date/20191110181201-feature-bad.md",
      fn ->
        compile_quoted(
          quote do
            defmodule ChangixBadDate do
              use Changix, path: "test/fixtures/changelog_bad_date"
            end
          end
        )
      end
    )
  end

  test "changelog_entry without header cannot compile" do
    assert_error(
      "Invalid entry structure for file test/fixtures/changelog_missing_header/20191110181201-feature-bad.md",
      fn ->
        compile_quoted(
          quote do
            defmodule ChangixMissingHeader do
              use Changix, path: "test/fixtures/changelog_missing_header"
            end
          end
        )
      end
    )
  end

  test "changelog_entry with invalid header cannot compile" do
    assert_error(
      "Missing required header fields for file test/fixtures/changelog_invalid_header/20191110181201-feature-bad.md",
      fn ->
        compile_quoted(
          quote do
            defmodule ChangixInvalidHeader do
              use Changix, path: "test/fixtures/changelog_invalid_header"
            end
          end
        )
      end
    )
  end

  defp assert_error(message, fun) do
    assert_raise RuntimeError, message, fun
  end

  defp compile_quoted(ast) do
    Code.eval_quoted(ast, [], __ENV__)
  end
end
