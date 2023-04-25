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

  def variable(%E4vm{} = vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> variable")

    vm
  end

  # создает константу ( x "<spaces>name" -- )
  def constant(%E4vm{} = vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> constant")

    # AddHeader(ReadWord(Input));
    # AddOp(LookUp("doList").Address);
    # AddOp(LookUp("doLit").Address);
    # AddOp(DS.Pop());
    # AddOp(LookUp("exit").Address);

    case E4vm.read_word(vm) do
      {vm, :end} ->
        IO.inspect(label: ">>>> constant NO WORDS")
        vm
      {new_vm, word} ->
        IO.inspect(word, label: ">>>> constant word")
        # word_addr = E4vm.look_up_word_address(new_vm, word)
        # IO.inspect(word_addr, label: ">>>> word_addr")
        # next_ds = Stack.push(new_vm.ds, word_addr)
        # %E4vm{new_vm | ds: next_ds}

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
