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

  def constant(%E4vm{} = vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> constant")

    vm
  end
end
