defmodule E4vm.Words.CommentTest do
  use ExUnit.Case

  test "test comment line" do
    vm = E4vm.new()
    |> E4vm.eval("1234 \\ comment to the end of the line \r\n 4321")

    assert "#Stack<[4321, 1234]>" == inspect(vm.ds)
  end

  test "test comment" do
    vm = E4vm.new()
    |> E4vm.eval("1234 ( some comment ) 4321")    # положит 1234 и 4321 на стек

    assert "#Stack<[4321, 1234]>" == inspect(vm.ds)
  end
end
