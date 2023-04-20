defmodule E4vmTest do
  use ExUnit.Case
  alias Structure.Stack
  import ExUnit.CaptureLog


  # - последовательность команд в памяти, начинающаяся с какого-то адреса - это пользовательское слово.
  # - пользовательское слово должно начинаться с doList (IP -> RS, WP+1 -> IP)
  # - пользовательское слово заканчивается на exit (RS -> IP)

  # - вызов пользовательского слова из другого слова - это просто адрес

  # - запуск и остановка машины
  # - перед запуском с произвольного адреса, нужно выполнить 2 действия
  # - поместить 0 -> IP и стартовый_адрес -> WP
  # - выполнить команду doList которая поместит 0 в стек возвратов RS и поместит стартовый адрес в IP
  #   0 в стеке возвратов при выполнении exit в конце слова поместит обратно 0 -> IP
  #   и следующий next остановит машину потому что достигнем IP=0
  # - выполнить команду next, которая начнет последовательно выполнять слова вызывая саму себя в цикле

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
      # |> IO.inspect(label: ">>>> vm")
      |> E4vm.Words.Core.do_list() # выполняем команду начала интерпретации слова, сохраняя IP = 0 на стеке возвратов
      |> E4vm.Words.Core.next()    # запускаем адресный интерпретатор

    assert_receive :hello
  end

  test "more simple start test" do
    Process.register(self(), :test_proc)

    vm = E4vm.new()
      |> E4vm.add_core_word("hello2",  {E4vmTest, :hello},   false)
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("hello2")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> IO.inspect(label: ">>>> vm")

    assert_receive :hello
  end


  test "more call/return simple start test" do
    Process.register(self(), :test_proc)

    vm = E4vm.new()
      |> E4vm.add_core_word("hello2",  {E4vmTest, :hello},   false)

    sub_word_address = vm.hereP

    vm
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("hello2")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op(sub_word_address)
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("exit")
      # |> IO.inspect(label: ">>>> vm")
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()

    assert_receive :hello
  end

  test "test doLit" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("doLit")
      |> E4vm.add_op(555)
      |> E4vm.add_op_from_string("exit")
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> IO.inspect(label: ">>>> vm")

    assert {:ok, 555} = Stack.head(vm.ds)
  end

  test "test branch" do
    Process.register(self(), :test_proc)

    vm = E4vm.new()
      |> E4vm.add_core_word("hello2",  {E4vmTest, :hello},   false)
      |> E4vm.here_to_wp()

    start_addr = vm.hereP

    vm = vm
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("branch")

    jmp_address = vm.hereP

    vm
      |> E4vm.add_op(jmp_address + 4)      # перепрыгнет через hello2. а если +2 перепрыгнет на hello2
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("hello2")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> IO.inspect(label: ">>>> vm")

    refute_receive :hello

    vm
      |> E4vm.add_op(jmp_address + 2)      # перепрыгнет через hello2. а если +2 перепрыгнет на hello2
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("hello2")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> IO.inspect(label: ">>>> vm")

    assert_receive :hello
  end

  test "test zbranch" do
    Process.register(self(), :test_proc)

    vm = E4vm.new()
      |> E4vm.add_core_word("hello2",  {E4vmTest, :hello},   false)
      |> E4vm.here_to_wp()

    start_addr = vm.hereP

    vm = vm
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("0branch")
      |> Map.merge(%{ds: Stack.push(vm.ds, 0)})

    jmp_address = vm.hereP

    vm
      |> E4vm.add_op(jmp_address + 4)      # перепрыгнет через hello2
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("hello2")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> IO.inspect(label: ">>>> vm")

    refute_receive :hello

    # -------------
    IO.puts("\r\n")

    vm = E4vm.new()
    |> E4vm.add_core_word("hello2",  {E4vmTest, :hello},   false)
    |> E4vm.here_to_wp()

    start_addr = vm.hereP

    vm = vm
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("0branch")
      |> Map.merge(%{ds: Stack.push(vm.ds, 1)})

    jmp_address = vm.hereP

    vm
      |> E4vm.add_op(jmp_address + 4)      # не перепрыгнет через hello2
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("hello2")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("nop")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> E4vm.inspect_core()

    assert_receive :hello

  end

  test "test here" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("here")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> E4vm.inspect_core()

    {:ok, top_ds} = Stack.head(vm.ds)
    assert vm.hereP == top_ds
  end

  test "test words" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("words")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
  end

  test "test dump" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("doLit")
      |> E4vm.add_op(0)
      |> E4vm.add_op_from_string("here")
      |> E4vm.add_op_from_string("dump")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
  end

  test "test [ ]" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("]")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()

      assert vm.is_eval_mode == false
  end

  test "test comma" do
    vm = E4vm.new()
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string(",")

    vm = vm
      |> Map.merge(%{ds: Stack.push(vm.ds, 0)})
      |> E4vm.add_op_from_string("exit")

    vm = vm
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()

    assert vm.mem[vm.hereP - 1] == 0
  end

  test "immediate test" do
    Process.register(self(), :test_proc)

    vm = E4vm.new()
      |> E4vm.add_core_word("hello2",  {E4vmTest, :hello},   false)
      |> E4vm.here_to_wp()

    assert {"hello2", {{E4vmTest, :hello}, false, _}} = hd(vm.entries)

    vm = vm
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("immediate")
      |> E4vm.add_op_from_string("exit")
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()

    assert {"hello2", {{E4vmTest, :hello}, true, _}} = hd(vm.entries)
  end

  test "end_def_word test" do
    vm = E4vm.new()

    #                                           immed  enabled
    last_word = {"hello2", {{E4vmTest, :hello}, false, false}}

    new_entries = [last_word] ++ vm.entries

    vm = %E4vm{vm | entries: new_entries, is_eval_mode: false}

    vm = vm
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string(";")
      |> E4vm.add_op_from_string("exit")
      # |> E4vm.inspect_core()

    assert vm.is_eval_mode == false
    [{word, {_addr, _immediate, enabled}}|tail] = vm.entries
    assert enabled == false
    old_here = vm.hereP

    vm = vm
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()
      # |> E4vm.inspect_core()

    assert vm.is_eval_mode == true
    [{word, {_addr, _immediate, enabled}}|tail] = vm.entries
    assert enabled == true
    assert (old_here + 1) == vm.hereP
    assert vm.mem[vm.hereP - 1] == E4vm.look_up_word_address(vm, "exit")
  end

  test "read_word test" do
    vm = E4vm.new()
    vm = %E4vm{vm | read_word_mfa: {E4vmTest, :word1, []}}

    assert E4vm.read_word(vm) == "word"
  end

  test "begin_def_word test" do
    vm = E4vm.new()
    vm = %E4vm{vm | read_word_mfa: {E4vmTest, :word2, []}}

    vm = vm
    |> E4vm.here_to_wp()
    |> E4vm.add_op_from_string("doList")
    |> E4vm.add_op_from_string(":")
    |> E4vm.add_op_from_string("exit")
    # |> E4vm.define("hui1", 555, true)
    # |> E4vm.add_header("hui2")
    # |> E4vm.add_op(0)
    |> E4vm.inspect_core()
    |> E4vm.Words.Core.do_list()
    |> E4vm.Words.Core.next()
    # |> E4vm.inspect_core()
  end

  # обычное слово из core
  test "execute1 test" do
    Process.register(self(), :test_proc)

    vm = E4vm.new()
      |> E4vm.add_core_word("hello2",  {E4vmTest, :hello},   false)
      |> E4vm.here_to_wp()
      |> E4vm.add_op_from_string("doList")
      |> E4vm.add_op_from_string("execute")
      |> E4vm.add_op_from_string("exit")

    vm = vm
      |> Map.merge(%{ds: Stack.push(vm.ds, E4vm.look_up_word_address(vm, "hello2"))})
      |> E4vm.inspect_core()
      |> E4vm.Words.Core.do_list()
      |> E4vm.Words.Core.next()

    assert_receive :hello
  end

  test "is_constant test" do
    assert E4vm.is_constant("123") == true
    assert E4vm.is_constant("+1") == true
    assert E4vm.is_constant("+12") == true
    assert E4vm.is_constant("+123") == true
    assert E4vm.is_constant("-1") == true
    assert E4vm.is_constant("-12") == true
    assert E4vm.is_constant("-123") == true
    assert E4vm.is_constant("h") == false
    assert E4vm.is_constant("-h") == false
    assert E4vm.is_constant("+h") == false
  end

  test "eval test" do
    Process.register(self(), :test_proc)

    vm = E4vm.new()
      |> E4vm.add_core_word("hello2",  {E4vmTest, :hello},   false)
      |> E4vm.here_to_wp()

    vm
      # |> E4vm.inspect_core()
      |> E4vm.eval("hello2") # выполнит hello2

    assert_receive :hello

    tvm = vm
      # |> E4vm.inspect_core()
      |> E4vm.eval("123")    # положит 123 на стек
      # |> E4vm.inspect_core()

    {:ok, top_ds} = Stack.head(tvm.ds)
    assert top_ds == 123


    {_result, log} =
      with_log(fn ->

      tvm = vm
        |> E4vm.eval("undefined_word")    # ошибка

    end)

    assert log =~ "is undefined"

    # program mode
    # если у нас режим программирования и слово immediate то оно должно немедленно выполниться
    #                                           immed  enabled
    last_word = {"hello2", {{E4vmTest, :hello}, true, true}}
    new_entries = [last_word] ++ vm.entries
    tvm = %E4vm{vm | entries: new_entries, is_eval_mode: false}

    tvm
      |> E4vm.eval("hello2")
      # |> E4vm.inspect_core()

    assert_receive :hello

    # а если не immediate то не должно выполниться. а должно добавиться в память
    last_word = {"hello2", {{E4vmTest, :hello}, false, true}}
    new_entries = [last_word] ++ vm.entries
    tvm = %E4vm{vm | entries: new_entries, is_eval_mode: false}

    ttvm = tvm
      |> E4vm.eval("hello2")
      # |> E4vm.inspect_core()

    refute_receive :hello
    # в памяти должно добавиться слово
    assert length(Map.keys(tvm.mem)) == length(Map.keys(ttvm.mem)) - 1
    # и это слово должно быть hello2
    assert E4vm.look_up_word_address(ttvm, "hello2") == ttvm.mem[(ttvm.hereP - 1)]

    # а если это число, то добавить dolit число в память
    last_word = {"hello2", {{E4vmTest, :hello}, false, true}}
    new_entries = [last_word] ++ vm.entries
    tvm = %E4vm{vm | entries: new_entries, is_eval_mode: false}

    ttvm = tvm
      |> E4vm.eval("123")
      # |> E4vm.inspect_core()

    # в памяти должно добавиться два слова
    assert length(Map.keys(tvm.mem)) == length(Map.keys(ttvm.mem)) - 2
    # и это слово должно быть
    assert E4vm.look_up_word_address(ttvm, "doLit") == ttvm.mem[(ttvm.hereP - 2)] # doLit
    assert 123 == ttvm.mem[(ttvm.hereP - 1)] # doLit

    # vm
    #   |> E4vm.eval(":  test1    hello hello ;")
    #   |> E4vm.inspect_core()


  end

  # слово определенное через :
  test "execute2 test" do
    vm = E4vm.new()


  end

  def word1() do
    "word"
  end

  def word2() do
    "defined_word"
  end

  def hello(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>TEST>>>> hello  ")

    IO.puts("Hello test")

    send(:test_proc, :hello)

    vm
  end
end
