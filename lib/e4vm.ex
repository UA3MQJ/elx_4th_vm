defmodule WordHeader do
  # addres адрес
  # immediate дает указание интерпретатору, что слово должно быть
  # выполнено в режиме программирования, а не записано в память
  defstruct address: 0,
            immediate: false # флаг немедленной интерпретации.
end

defmodule E4vm do
  @moduledoc """
  Documentation for `E4vm`.
  """
  defstruct mem: %{}, # память программ
            rs: Structure.Stack.new(), # Стек возвратов
            ds: Structure.Stack.new(), # Стек данных
            ip: 0,                     # Указатель инструкций
            wp: 0,                     # Указатель слова
            core: %{},                 # Base instructions
            entries: [],               # Word header dictionary
            hereP: 0                   # Here pointer


  alias Structure.Stack

  def new() do

    %E4vm{}
    # core
    |> add_core_word("nop",    {E4vm, :nop},     false)
    |> add_core_word("halt",   {E4vm, :halt},    false)
    |> add_core_word("next",   {E4vm, :next},    false)
    |> add_core_word("doList", {E4vm, :do_list}, false)
    |> add_core_word("exit",   {E4vm, :exit},    false)
    # execute
    |> add_core_word("doLit",  {E4vm, :do_lit},  false)
  end

  def add_core_word(%E4vm{} = vm, word, handler, immediate) do
    address = vm.hereP
    # new_core = [handler] ++ vm.core
    new_core = Map.merge(vm.core, %{vm.hereP => handler})

    vm
    |> Map.merge(%{core: new_core})
    |> define(word, handler, immediate)
    |> add_address_to_mem(address)
    |> inc_here()
  end

  defp define(%E4vm{} = vm, word, entry, immediate) do
    entry = {word, {entry, immediate}}
    %E4vm{vm| entries: [entry] ++ vm.entries}
  end

  defp add_address_to_mem(%E4vm{} = vm, address) do
    new_mem = Map.merge(vm.mem, %{address => address})
    %E4vm{vm| mem: new_mem}
  end

  defp inc_here(%E4vm{} = vm) do
    %E4vm{vm| hereP: vm.hereP + 1}
  end

  # lookup - поиск слова и адреса слова
  def look_up_word(%E4vm{} = vm, word) do
    case :proplists.get_value(word, vm.entries) do
      :undefined -> :undefined
      {{_m, _f} = word, _immediate} -> word
    end
  end

  def look_up_word_address(%E4vm{} = vm, word) do
    case look_up_word(vm, word) do
      :undefined -> :undefined
      {_m, _f} = word ->
        vm.core
          |> Enum.find(fn {_key, val} -> val == word end)
          |> elem(0)
    end
  end

  # добавляем операцию в память. то есть в here кладем  адрес слова
  def add_op(%E4vm{} = vm, addr) do
    new_mem = Map.merge(vm.mem, %{vm.hereP => addr})
    %E4vm{vm| hereP: vm.hereP + 1, mem: new_mem}
  end

  # это больше нужно для pipe'ов потому что вложенную фунцию в пайпе не вызвать с входными данными (или можно?)
  def add_op_from_string(%E4vm{} = vm, word) do
    addr = look_up_word_address(vm, word)
    new_mem = Map.merge(vm.mem, %{vm.hereP => addr})
    %E4vm{vm| hereP: vm.hereP + 1, mem: new_mem}
  end

  # Останавливаемся, если адрес 0
  def next(%E4vm{ip: 0} = vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> next ok")

    vm
  end

  # Суть интерпретации заключается в переходе по адресу в памяти и в исполнении инструкции, которая там указана.
  def next(vm) do
    # vm |> IO.inspect(label: ">>>>>>>>>>>> next")
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> next   ")

    # выбираем адрес следующей инструкции
    next_wp = vm.mem[vm.ip]
    # увеличиваем указатель инструкций
    next_ip = vm.ip + 1
    new_vm = %E4vm{vm | ip: next_ip, wp: next_wp}

    # по адресу следующего указателя на слово
    # выбираем адрес инструкции из памяти
    # и по адресу определяем команду с помощью хранилища примитовов
    # next_wp |> IO.inspect(label: ">>>>>>>>>>>> next next_wp")
    # new_vm.mem[next_wp] |> IO.inspect(label: ">>>>>>>>>>>> next mem[next_wp]")

    # {m, f} = Enum.at(vm.core, length(vm.core)-(new_vm.mem[next_wp])-1)
    {m, f} = vm.core[new_vm.mem[next_wp]]
      # |> IO.inspect(label: ">>>>>>>>>>>> next execute")

    # выполняем эту команду
    next_new_vm = apply(m, f, [new_vm])
      # |> IO.inspect(label: ">>>>>>>>>>>> next next_new_vm")

    next(next_new_vm)
  end

  # Каждое пользовательское слово начинается с команды DoList,
  # задача которой — сохранить текущий адрес интерпретации на стеке
  # и установить адрес интерпретации следующего слова.
  def do_list(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> do_list")

    next_rs = Stack.push(vm.rs, vm.ip)
    next_ip = vm.wp + 1

    %E4vm{vm | ip: next_ip, rs: next_rs}
  end

  # команда для выхода из слова
  # восстанавливает адрес указателя инструкций IP со стека возвратов RS
  def exit(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> exit   ")

    {:ok, next_ip} = Stack.head(vm.rs)
    {:ok, next_rs} = Stack.pop(vm.rs)

    %E4vm{vm | ip: next_ip, rs: next_rs}
  end

  # нет операции
  def nop(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> nop    ")
    vm
  end

  # остановка
  def halt(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> halt   ")
    %E4vm{vm | ip: 0}
  end

  # Чтобы при интерпретации отличить числовую константу от адреса слова,
  # при компиляции перед каждой константой компилируется вызов слова doLit,
  # которое считывает следующее значение в памяти и размещает его на стеке данных.
  def do_lit(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> do_lit ")
    next_ds = Stack.push(vm.ds, vm.mem[vm.ip])
    next_ip = vm.ip + 1

    %E4vm{vm | ip: next_ip, ds: next_ds}
  end

  # сохранить текущее here в wp чтобы это место считать стартовым для программы
  def here_to_wp(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> here->wp")
    %E4vm{vm | wp: vm.hereP}
  end
end
