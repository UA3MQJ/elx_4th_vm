defmodule E4vm.Words.MemTest do
  use ExUnit.Case
  alias Structure.Stack
  alias E4vm.Words.MemTest
  import ExUnit.CaptureLog

  test "test write mem !" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("!")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.ds_push(1)
      |> E4vm.ds_push(555)
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> E4vm.inspect_core()

    # в памяти по адресу 555 должна быть записана 1
    assert vm.mem[555] == 1
  end

  test "test read mem @" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("@")
      |> E4vm.add_op_from_string("exit")

    # поместим в память по адресу 555 значение 444
    new_mem = Map.merge(vm.mem, %{555 => 444})
    vm = %{vm| mem: new_mem}

    # и поместим в стек адрес - 555 чтобы считать значение
    vm = vm
      |> E4vm.ds_push(555)
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> E4vm.inspect_core()

    # в стеке адрес 555 должен замениться на значение из этой ячейки - 444
    assert Stack.size(vm.ds) == 1
    assert {:ok, 444} = Stack.head(vm.ds)
  end

  test "test variable" do
    vm = E4vm.new()
      |> E4vm.eval("variable X1") # определили переменную
      |> E4vm.eval("X1") # должна в стек положить адрес переменной
      # |> E4vm.inspect_core()

      # в стеке должен быть адрес переменной должен быть перед определением x1 в памяти, те -1
      assert Stack.size(vm.ds) == 1
      x1_addr = E4vm.look_up_word_address(vm, "X1") - 1
      assert {:ok, ^x1_addr} = Stack.head(vm.ds)
  end

  test "test constant" do
    vm = E4vm.new()
      |> E4vm.eval("123 constant X123") # определили константу
      |> E4vm.eval("X123") # должна в стек положить 123
      # |> E4vm.inspect_core()

      # в стеке должно быть значение константы 123
      assert Stack.size(vm.ds) == 1
      assert {:ok, 123} = Stack.head(vm.ds)
  end

  # -----------------------
  def word1() do
    "word"
  end

  def word2() do
    "defined_word"
  end

  def word3(vm) do
    [hd|tail] = vm.read_word_state

    new_vm = %{vm| read_word_state: tail}

    {new_vm, hd}
  end

  def hello(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>TEST>>>> hello  ")

    IO.puts("Hello test")

    send(:test_proc, :hello)

    vm
  end
end
