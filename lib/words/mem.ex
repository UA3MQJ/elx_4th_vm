defmodule E4vm.Words.Mem do
  alias Structure.Stack

  # запись в память ! ( x a-addr -- )
  def write_mem(%E4vm{} = vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> !")

    {:ok, address} = Stack.head(vm.ds)
    {:ok, next_ds} = Stack.pop(vm.ds)

    {:ok, data} = Stack.head(next_ds)
    {:ok, next_ds} = Stack.pop(next_ds)

    next_mem = Map.merge(vm.mem, %{address => data})

    %E4vm{vm | ds: next_ds, mem: next_mem}
  end

  # чтение из памяти @ ( a-addr -- x )
  def read_mem(%E4vm{} = vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> @")

    {:ok, address} = Stack.head(vm.ds)
    {:ok, next_ds} = Stack.pop(vm.ds)

    next_ds = Stack.push(next_ds, vm.mem[address])

    %E4vm{vm | ds: next_ds}
  end

  # создает переменную ( -- a-addr )
  def variable(%E4vm{} = vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> variable")

    # var here = Here++;
    # AddHeader(ReadWord(Input));
    # AddOp(LookUp("doList").Address);
    # AddOp(LookUp("doLit").Address);
    # AddOp(here);
    # AddOp(LookUp("exit").Address);

    here = vm.hereP

    vm = %E4vm{vm | hereP: vm.hereP + 1}

    case E4vm.read_word(vm) do
      {vm, :end} ->
        IO.inspect(label: ">>>> variable NO WORDS")
        vm
      {new_vm, word} ->
        IO.inspect(word, label: ">>>> variable word")

        %E4vm{new_vm | mem: Map.merge(new_vm.mem, %{here => nil})} # инициирую адрес. но пустым значением
          |> E4vm.add_header(word)  # <- add_header должен стоять первым!
          |> E4vm.add_op_from_string("doList")
          |> E4vm.add_op_from_string("doLit")
          |> E4vm.add_op(here)
          |> E4vm.add_op_from_string("exit")
    end
  end

  # создает константу ( x "<spaces>name" -- )
  def constant(%E4vm{} = vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> constant")

    case E4vm.read_word(vm) do
      {vm, :end} ->
        IO.inspect(label: ">>>> constant NO WORDS")
        vm
      {new_vm, word} ->

        {:ok, address} = Stack.head(new_vm.ds)
        {:ok, next_ds} = Stack.pop(new_vm.ds)

        %E4vm{new_vm | ds: next_ds}
          |> E4vm.add_header(word)  # <- add_header должен стоять первым!
          |> E4vm.add_op_from_string("doList")
          |> E4vm.add_op_from_string("doLit")
          |> E4vm.add_op(address)
          |> E4vm.add_op_from_string("exit")

    end
  end
end
