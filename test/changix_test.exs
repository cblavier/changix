defmodule ChangixTest do
  use ExUnit.Case

  defmodule ChangixStub do
    use Changix, path: "test/fixtures/changelog"
  end

  test "changelog_entry_count" do
    assert ChangixStub.changelog_entry_count() == 2
  end

  test "changelog_entry with index" do
    assert ChangixStub.changelog_entry(0).date == ~D[2019-11-12]
    assert ChangixStub.changelog_entry(1).date == ~D[2019-11-10]
  end
end
