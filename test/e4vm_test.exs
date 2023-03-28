defmodule E4vmTest do
  use ExUnit.Case
  alias Structure.Stack
  doctest E4vm

  test "greets the world new" do
    Process.register(self(), :test_proc)
    vm = E4vm.new()

    # mem = Map.merge(vm.mem, %{
    #   # program
    #   10 => 2, # @do_list,  # 3) сохраняем адрес интерпретации
    #   11 => 5, # @hello2    # 4) выводим на экран сообщение
    #   12 => 3, # @exit,     # 5) выходим из слова, восстанавливаем IP = 9 со стека возвратов
    #   13 => 2, # @do_list,  # 1) точка входа в подпрограмму - выполнить команду по адресу 10
    #   14 => 10,# 10,        # 2) вызов подпрограммы по адресу 10, устанавливаем WP = 10
    #   15 => 3  # @exit
    # })

    vm = vm
      |> E4vm.add_core_word("hello2",  {E4vmTest, :hello},   false)

    start_program_addr = vm.hereP

    vm = vm
      |> E4vm.add_op(E4vm.look_up_word_address(vm, "doList"))
      |> E4vm.add_op(E4vm.look_up_word_address(vm, "hello2"))
      |> E4vm.add_op(E4vm.look_up_word_address(vm, "exit"))
      |> E4vm.add_op(E4vm.look_up_word_address(vm, "doList")) # <- точка входа here - 3
      |> E4vm.add_op(start_program_addr)
      |> E4vm.add_op(E4vm.look_up_word_address(vm, "exit"))
      # <- hereP

    vm = %E4vm{vm | ip: 0, wp: vm.hereP - 3}
      |> IO.inspect(label: ">>>> vm")
      |> E4vm.do_list() # выполняем команду начала интерпретации слова, сохраняя IP = 0 на стеке возвратов
      |> E4vm.next()    # запускаем адресный интерпретатор

    assert_receive :hello
  end

  test "more simple start test" do
    Process.register(self(), :test_proc)

    vm = E4vm.new()
      |> E4vm.add_core_word("hello2",  {E4vmTest, :hello},   false)
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("hello2")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("halt")
      |> E4vm.do_list()
      |> E4vm.next()
      |> IO.inspect(label: ">>>> vm")

    assert_receive :hello
  end

  test "more more simple start test" do
    Process.register(self(), :test_proc)

    vm = E4vm.new()
      |> E4vm.add_core_word("hello2",  {E4vmTest, :hello},   false)
      |> E4vm.here_to_ip()
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("hello2")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("halt")
      |> E4vm.next()

    assert_receive :hello
  end

  test "test doLit" do
    vm = E4vm.new()
      |> E4vm.here_to_ip()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("doLit")
      |> E4vm.add_op(555)
      |> E4vm.add_op_from_string("halt")
      |> E4vm.next()

    assert {:ok, 555} = Stack.head(vm.ds)
  end

  def hello(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>TEST>>>> hello  ")

    IO.puts("Hello test")

    send(:test_proc, :hello)

    vm
  end
end
