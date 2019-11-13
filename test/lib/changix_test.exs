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
    assert Date.to_erl(first.datetime) >= Date.to_erl(last.datetime)
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
    assert entry.datetime == ~N[2019-11-10T17:10:05]
    assert entry.kind == :bugfix
    assert entry.kind_label == "Bugfix"
  end

  test "changelog_entry with binary dates" do
    assert ChangixStub.changelog_entry("2019-11-10T17:10:05").datetime == ~N[2019-11-10T17:10:05]
    assert ChangixStub.changelog_entry("2019-11-10T18:12:01").datetime == ~N[2019-11-10T18:12:01]
  end

  test "changelog_entry with unknown entry" do
    assert is_nil(ChangixStub.changelog_entry(:foo))
  end

  test "changelog_entry with bad date cannot compile" do
    assert_error(
      "Invalid datetime in header for file test/fixtures/changelog_bad_date/20191110181201-feature-bad.md",
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
