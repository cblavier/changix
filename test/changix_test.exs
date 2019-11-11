defmodule ChangixTest do
  use ExUnit.Case

  defmodule ChangixStub do
    use Changix
  end

  test "greets the world" do
    assert ChangixStub.hello() == :world
  end
end
