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

  test "changelog_entry with unknown entry" do
    assert is_nil(ChangixStub.changelog_entry(:foo))
  end
end
