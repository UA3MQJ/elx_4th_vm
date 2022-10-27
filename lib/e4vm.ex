defmodule E4vm do
  @moduledoc """
  Documentation for `E4vm`.
  """
  defstruct mem: %{}, # память программ
            rs: Structure.Stack.new(), # Стек возвратов
            ds: Structure.Stack.new(), # Стек данных
            ip: 0,                     # Указатель инструкций
            wp: 0,                     # Указатель слова
            core: %{}                  # хранилище примитивов


  alias Structure.Stack

  @next    0
  @do_list 1
  @exit    2
  @hello   3

  def new() do
    core = %{
      @next    => {E4vm, :next},
      @do_list => {E4vm, :do_list},
      @exit    => {E4vm, :exit},
      @hello   => {E4vm, :hello}
    }

    mem = %{
      0 => @next,
      1 => @do_list,
      2 => @exit,
      3 => @hello,
      4 => @do_list,
      5 => @hello,
      6 => @exit,
      7 => @do_list,
      8 => 4,
      9 => @exit
    }
    %E4vm{core: core, mem: mem}
  end

  def next(%E4vm{ip: 0} = vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> next ok")

    vm
  end

  def next(vm) do
    # vm |> IO.inspect(label: ">>>>>>>>>>>> next")
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> next   ")

    next_wp = vm.mem[vm.ip]
    next_ip = vm.ip + 1
    new_vm = %E4vm{vm | ip: next_ip, wp: next_wp}

    {m, f} = new_vm.core[new_vm.mem[new_vm.wp]]
    #  |> IO.inspect(label: ">>>>>>>>>>>> next execute")

    next_new_vm = apply(m, f, [new_vm])

    next(next_new_vm)
    # next_new_vm
  end

  def do_list(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> do_list")

    next_rs = Stack.push(vm.rs, vm.ip)
    next_ip = vm.wp + 1

    %E4vm{vm | ip: next_ip, rs: next_rs}
  end

  def exit(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> exit   ")

    {:ok, next_ip} = Stack.head(vm.rs)
    {:ok, next_rs} = Stack.pop(vm.rs)

    %E4vm{vm | ip: next_ip, rs: next_rs}
  end

  def hello(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> hello  ")

    IO.puts("Hello")
    vm
  end
end
