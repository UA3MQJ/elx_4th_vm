defmodule E4vm.Words.StackTest do
  use ExUnit.Case
  alias Structure.Stack
  alias E4vm.Words.StackTest
  import ExUnit.CaptureLog

  # удалить слово со стека ( x -- )
  test "test stack drop" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("drop")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.ds_push(1)
      |> E4vm.ds_push(2)
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> E4vm.inspect_core()

    # [2, 1] -> [1]
    assert Stack.size(vm.ds) == 1
    assert {:ok, 1} = Stack.head(vm.ds)
  end

  # обменять местами ( x1 x2 -- x2 x1 )
  test "test stack swap" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("swap")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.ds_push(1)
      |> E4vm.ds_push(2)
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> E4vm.inspect_core()

    # [2, 1] -> [1, 2]
    assert Stack.size(vm.ds) == 2
    assert "#Stack<[1, 2]>" == inspect(vm.ds)
  end

  # дублировать слово на вершине стека ( x -- x x )
  test "test stack dup" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("dup")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.ds_push(1)
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> E4vm.inspect_core()

    # [1] -> [1, 1]
    assert Stack.size(vm.ds) == 2
    assert "#Stack<[1, 1]>" == inspect(vm.ds)
  end

  #                                                                      top
  # положить копию второго элемента стека на верх стека ( x1 x2 -- x1 x2 x1 )
  test "test stack over" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("over")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.ds_push(1)
      |> E4vm.ds_push(2)
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> E4vm.inspect_core()

    # [1, 2] -> [1, 2, 1]
    assert Stack.size(vm.ds) == 3
    assert "#Stack<[1, 2, 1]>" == inspect(vm.ds)
  end

  # развернуть три элемента на стеке ( x1 x2 x3 -- x2 x3 x1 )
  test "test stack rot" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("rot")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.ds_push(1)
      |> E4vm.ds_push(2)
      |> E4vm.ds_push(3)
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> E4vm.inspect_core()

    assert Stack.size(vm.ds) == 3
    assert "#Stack<[2, 3, 1]>" == inspect(vm.ds)
  end

  # развернуть три элемента на стеке в другую сторону ( x1 x2 x3 -- x3 x1 x2 )
  test "test stack nrot" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("nrot")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.ds_push(1)
      |> E4vm.ds_push(2)
      |> E4vm.ds_push(3)
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> E4vm.inspect_core()

    assert Stack.size(vm.ds) == 3
    assert "#Stack<[3, 1, 2]>" == inspect(vm.ds)
  end

end
