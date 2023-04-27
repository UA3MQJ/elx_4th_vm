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
    vm = E4vm.new()
    |> E4vm.Utils.ds_push(elem(Integer.parse("110", 2), 0))
    |> E4vm.Utils.ds_push(elem(Integer.parse("011", 2), 0))
    |> E4vm.Words.Boolean.bool_and()

    assert "#Stack<[2]>" == inspect(vm.ds)
  end

  test "test or :bool_or" do
    vm = E4vm.new()
    |> E4vm.Utils.ds_push(elem(Integer.parse("10", 2), 0))
    |> E4vm.Utils.ds_push(elem(Integer.parse("01", 2), 0))
    |> E4vm.Words.Boolean.bool_or()

    assert "#Stack<[3]>" == inspect(vm.ds)
  end

  test "test xor :bool_xor" do
    vm = E4vm.new()
    |> E4vm.Utils.ds_push(elem(Integer.parse("110", 2), 0))
    |> E4vm.Utils.ds_push(elem(Integer.parse("011", 2), 0))
    |> E4vm.Words.Boolean.bool_xor()

    assert "#Stack<[5]>" == inspect(vm.ds)
  end

  test "test = :bool_eql" do
    vm = E4vm.new()
    |> E4vm.Utils.ds_push(elem(Integer.parse("110", 2), 0))
    |> E4vm.Utils.ds_push(elem(Integer.parse("110", 2), 0))
    |> E4vm.Words.Boolean.bool_eql()

    assert "#Stack<[65535]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(elem(Integer.parse("110", 2), 0))
    |> E4vm.Utils.ds_push(elem(Integer.parse("011", 2), 0))
    |> E4vm.Words.Boolean.bool_eql()

    assert "#Stack<[0]>" == inspect(vm.ds)
  end

  test "test <> :bool_not_eql" do
    vm = E4vm.new()
    |> E4vm.Utils.ds_push(elem(Integer.parse("110", 2), 0))
    |> E4vm.Utils.ds_push(elem(Integer.parse("110", 2), 0))
    |> E4vm.Words.Boolean.bool_not_eql()

    assert "#Stack<[0]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(elem(Integer.parse("110", 2), 0))
    |> E4vm.Utils.ds_push(elem(Integer.parse("011", 2), 0))
    |> E4vm.Words.Boolean.bool_not_eql()

    assert "#Stack<[65535]>" == inspect(vm.ds)
  end

  test "test < :bool_less" do
    vm = E4vm.new()
    |> E4vm.Utils.ds_push(1)
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Words.Boolean.bool_less()

    assert "#Stack<[65535]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Utils.ds_push(1)
    |> E4vm.Words.Boolean.bool_less()

    assert "#Stack<[0]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Words.Boolean.bool_less()

    assert "#Stack<[0]>" == inspect(vm.ds)
  end

  test "test > :bool_greater" do
    vm = E4vm.new()
    |> E4vm.Utils.ds_push(1)
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Words.Boolean.bool_greater()

    assert "#Stack<[0]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Utils.ds_push(1)
    |> E4vm.Words.Boolean.bool_greater()

    assert "#Stack<[65535]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Words.Boolean.bool_less()

    assert "#Stack<[0]>" == inspect(vm.ds)
  end

  test "test <= :bool_less_eql" do
    vm = E4vm.new()
    |> E4vm.Utils.ds_push(1)
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Words.Boolean.bool_less_eql()

    assert "#Stack<[65535]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Utils.ds_push(1)
    |> E4vm.Words.Boolean.bool_less_eql()

    assert "#Stack<[0]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Words.Boolean.bool_less_eql()

    assert "#Stack<[65535]>" == inspect(vm.ds)
  end

  test "test >= :bool_greater_eql" do
    vm = E4vm.new()
    |> E4vm.Utils.ds_push(1)
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Words.Boolean.bool_greater_eql()

    assert "#Stack<[0]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Utils.ds_push(1)
    |> E4vm.Words.Boolean.bool_greater_eql()

    assert "#Stack<[65535]>" == inspect(vm.ds)

    vm = E4vm.new()
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Utils.ds_push(2)
    |> E4vm.Words.Boolean.bool_greater_eql()

    assert "#Stack<[65535]>" == inspect(vm.ds)
  end
end
