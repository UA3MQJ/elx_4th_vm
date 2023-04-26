defmodule E4vm.Words.BooleanTest do
  use ExUnit.Case

  test "test true :bool_true" do
    vm = E4vm.new()
    |> E4vm.Words.Boolean.bool_true()

    assert "#Stack<[65535]>" == inspect(vm.ds)
  end

  test "test false :bool_false" do
    vm = E4vm.new()
    |> E4vm.Words.Boolean.bool_false()

    assert "#Stack<[0]>" == inspect(vm.ds)
  end

  test "test not :bool_not" do
    vm = E4vm.new()
    |> E4vm.Utils.ds_push(0)
    |> E4vm.Words.Boolean.bool_not()

    assert "#Stack<[65535]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(65535)
    |> E4vm.Words.Boolean.bool_not()

    assert "#Stack<[0]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(1234)
    |> E4vm.Words.Boolean.bool_not()

    assert "#Stack<[1234]>" == inspect(vm.ds)
  end

  test "test invert :bool_invert" do
    vm = E4vm.new()
    |> E4vm.Utils.ds_push(0)
    |> E4vm.Words.Boolean.bool_invert()

    assert "#Stack<[65535]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(255)
    |> E4vm.Words.Boolean.bool_invert()

    assert "#Stack<[65280]>" == inspect(vm.ds)
  end

  test "test and :bool_and" do

  end

  test "test or :bool_or" do

  end

  test "test xor :bool_xor" do

  end

  test "test = :bool_eql" do

  end

  test "test <> :bool_not_eql" do

  end

  test "test < :bool_less" do

  end

  test "test > :bool_greater" do

  end


  test "test <= :bool_less_eql" do

  end

  test "test >= :bool_greater_eql" do

  end
end
