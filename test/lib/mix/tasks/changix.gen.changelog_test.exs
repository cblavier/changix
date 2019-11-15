defmodule Mix.Tasks.Changix.Gen.ChangelogTest do
  use ExUnit.Case
  alias Mix.Tasks.Changix.Gen.Changelog

  setup do
    folder = "tmp"
    File.rm_rf!(folder)

    on_exit(fn ->
      File.rm_rf!(folder)
    end)

    {:ok, %{folder: folder}}
  end

  test "omitting title must raise" do
    assert_raise Mix.Error,
                 "expected mix changix.gen.changelog to take the changelog title",
                 fn ->
                   Changelog.run([])
                 end
  end

  test "generate changelog with title", %{folder: folder} do
    Changelog.run(["foo", "--folder", folder])
    assert_file(folder, "*-foo.md", "title: foo")
  end

  test "generate changelog with uppercase title", %{folder: folder} do
    Changelog.run(["Foo", "--folder", folder])
    assert_file(folder, "*-foo.md", "title: Foo")
  end

  test "generate changelog with multi part title", %{folder: folder} do
    Changelog.run(["Foo", "bar", "--folder", folder])
    assert_file(folder, "*-foo_bar.md", "title: Foo bar")
  end

  test "generate changelog with title and kind", %{folder: folder} do
    Changelog.run(["Foo", "--folder", folder, "--kind", "bugfix"])
    assert_file(folder, "*-foo.md", ["title: Foo", "kind: bugfix"])
  end

  test "generate changelog with aliases", %{folder: folder} do
    Changelog.run(["Foo", "-f", folder, "-k", "bugfix"])
    assert_file(folder, "*-foo.md", ["title: Foo", "kind: bugfix"])
  end

  defp assert_file(folder, pattern) do
    path = Path.join(File.cwd!(), folder)
    assert [file] = Path.wildcard("#{path}/#{pattern}")
  end

  defp assert_file(folder, pattern, match) do
    cond do
      is_list(match) ->
        assert_file(folder, pattern, &Enum.each(match, fn m -> assert &1 =~ m end))

      is_binary(match) or Regex.regex?(match) ->
        assert_file(folder, pattern, &assert(&1 =~ match))

      is_function(match, 1) ->
        file = assert_file(folder, pattern)
        match.(File.read!(file))

      true ->
        raise inspect({folder, pattern, match})
    end
  end
end
