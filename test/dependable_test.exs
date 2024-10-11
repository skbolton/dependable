defmodule DependableTest do
  use ExUnit.Case
  doctest Dependable

  test "greets the world" do
    assert Dependable.hello() == :world
  end
end
