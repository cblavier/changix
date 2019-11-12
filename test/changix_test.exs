defmodule ChangixTest do
  use ExUnit.Case

  defmodule ChangixStub do
    use Changix, path: "test/fixtures/changelog"
  end

  test "changelog_entry_count" do
    entries = ChangixStub.changelog_entries()
    assert length(entries) == 2
  end

  test "changelog_entry" do
    assert ChangixStub.changelog_entry(~D[2019-11-12]).date == ~D[2019-11-12]
    assert ChangixStub.changelog_entry(~D[2019-11-10]).date == ~D[2019-11-10]
  end

  test "changelog_entry with binary dates" do
    assert ChangixStub.changelog_entry("2019-11-12").date == ~D[2019-11-12]
    assert ChangixStub.changelog_entry("2019-11-10").date == ~D[2019-11-10]
  end

  # test "changelog_entry with kind labels"

  test "changelog_entry with unknown entry" do
    assert is_nil(ChangixStub.changelog_entry(:foo))
  end

  test "changelog_entry with bad date cannot compile" do
    assert_raise RuntimeError, "Invalid date in header for file 02-bad.md", fn ->
      compile_quoted(
        quote do
          defmodule ChangixBadDate do
            use Changix, path: "test/fixtures/changelog_bad_date"
          end
        end
      )
    end
  end

  test "changelog_entry without header cannot compile" do
    assert_raise RuntimeError, "Invalid entry structure for file 02-bad.md", fn ->
      compile_quoted(
        quote do
          defmodule ChangixMissingHeader do
            use Changix, path: "test/fixtures/changelog_missing_header"
          end
        end
      )
    end
  end

  test "changelog_entry with invalid header cannot compile" do
    assert_raise RuntimeError, "Missing required header fields for file 02-bad.md", fn ->
      compile_quoted(
        quote do
          defmodule ChangixInvalidHeader do
            use Changix, path: "test/fixtures/changelog_invalid_header"
          end
        end
      )
    end
  end

  defp compile_quoted(ast) do
    Code.eval_quoted(ast, [], __ENV__)
  end
end
