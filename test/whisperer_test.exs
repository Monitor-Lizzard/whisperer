defmodule WhispererTest do
  use ExUnit.Case
  doctest Whisperer

  test "greets the world" do
    assert Whisperer.hello() == :world
  end
end
