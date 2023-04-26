defmodule E4vm.Words.MathTest do
  use ExUnit.Case
  alias Structure.Stack

  test "test minus" do
    vm = E4vm.new()
      |> E4vm.ds_push(1)
      |> E4vm.ds_push(2)
      |> E4vm.Words.Math.minus()
      # |> E4vm.inspect_core()

    {:ok, ds_top} = Stack.head(vm.ds)
    assert ds_top == (1 - 2)
  end

  test "test plus" do
    vm = E4vm.new()
      |> E4vm.ds_push(1)
      |> E4vm.ds_push(2)
      |> E4vm.Words.Math.plus()
      # |> E4vm.inspect_core()

    {:ok, ds_top} = Stack.head(vm.ds)
    assert ds_top == (1 + 2)
  end

  test "test multiply" do
    vm = E4vm.new()
      |> E4vm.ds_push(2)
      |> E4vm.ds_push(3)
      |> E4vm.Words.Math.multiply()
      # |> E4vm.inspect_core()

    {:ok, ds_top} = Stack.head(vm.ds)
    assert ds_top == (2 * 3)
  end

  test "test devide" do
    vm = E4vm.new()
      |> E4vm.ds_push(10)
      |> E4vm.ds_push(2)
      |> E4vm.Words.Math.devide()
      # |> E4vm.inspect_core()

    {:ok, ds_top} = Stack.head(vm.ds)
    assert ds_top == 5
  end

  test "test mod" do
    vm = E4vm.new()
      |> E4vm.ds_push(10)
      |> E4vm.ds_push(2)
      |> E4vm.Words.Math.mod()
      # |> E4vm.inspect_core()

    {:ok, ds_top} = Stack.head(vm.ds)
    assert ds_top == 0
  end

  test "test inc" do
    vm = E4vm.new()
      |> E4vm.ds_push(10)
      |> E4vm.Words.Math.inc()
      # |> E4vm.inspect_core()

    {:ok, ds_top} = Stack.head(vm.ds)
    assert ds_top == 11
  end

  test "test dec" do
    vm = E4vm.new()
      |> E4vm.ds_push(10)
      |> E4vm.Words.Math.dec()
      # |> E4vm.inspect_core()

    {:ok, ds_top} = Stack.head(vm.ds)
    assert ds_top == 9
  end

  test "test math" do
    vm = E4vm.new()
    assert vm |> E4vm.eval("10 2 -") |> E4vm.Utils.ds_pop() == 8
    assert vm |> E4vm.eval("10 2 +") |> E4vm.Utils.ds_pop() == 12
    assert vm |> E4vm.eval("10 2 *") |> E4vm.Utils.ds_pop() == 20
    assert vm |> E4vm.eval("10 2 /") |> E4vm.Utils.ds_pop() == 5
    assert vm |> E4vm.eval("10 2 mod") |> E4vm.Utils.ds_pop() == 0
    assert vm |> E4vm.eval("10 1+") |> E4vm.Utils.ds_pop() == 11
    assert vm |> E4vm.eval("10 1-") |> E4vm.Utils.ds_pop() == 9
  end

end
