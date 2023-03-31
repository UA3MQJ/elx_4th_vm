defmodule E4vm.Words.Core do

  alias Structure.Stack

  # Останавливаемся, если адрес 0
  def next(%E4vm{ip: 0} = vm) do
    # "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> next ok")

    vm
  end

  # Суть интерпретации заключается в переходе по адресу в памяти и в исполнении инструкции, которая там указана.
  def next(vm) do
    # vm |> IO.inspect(label: ">>>>>>>>>>>> next")
    # "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> next   ")

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

  # Чтобы при интерпретации отличить числовую константу от адреса слова,
  # при компиляции перед каждой константой компилируется вызов слова doLit,
  # которое считывает следующее значение в памяти и размещает его на стеке данных.
  def do_lit(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> do_lit ")
    next_ds = Stack.push(vm.ds, vm.mem[vm.ip])
    next_ip = vm.ip + 1

    %E4vm{vm | ip: next_ip, ds: next_ds}
  end

  def execute(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> execute ")
    vm
  end

  def begin_def_word(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> begin_def_word ")
    vm
  end

  def end_def_word(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> end_def_word ")
    vm
  end

  # переход по адресу в следующей ячейке
  def branch(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> branch  ")

    next_ip = vm.mem[vm.ip]
    %E4vm{vm | ip: next_ip}
  end

  # переход по адресу, если в след ячейке 0. то есть false.
  # false - это все биты в ноле. true - это все биты одной ячейки(cell) в единице.
  def zbranch(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> zbranch ")

    {:ok, top_ds} = Stack.head(vm.ds)
    {:ok, next_ds} = Stack.pop(vm.ds)

    if top_ds==0 do
      # переходим
      # IO.inspect(label: ">>>>>>>>>>>> zbranch переходим")

      # vm |> E4vm.inspect_core()

      next_ip = vm.mem[vm.ip]
      %E4vm{vm | ip: next_ip, ds: next_ds}
    else
      # не переходим
      # IO.inspect(label: ">>>>>>>>>>>> zbranch не переходим")
      %E4vm{vm | ip: vm.ip, ds: next_ds}
    end
  end

  def get_here_addr(vm) do
    "ip:#{vm.ip} wp:#{vm.wp} here:#{vm.hereP}" |> IO.inspect(label: ">>>>>>>>>>>> here    ")
    # DS.Push(_hereP);
    next_ds = Stack.push(vm.ds, vm.hereP)

    %E4vm{vm | ds: next_ds}
  end

  def quit(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> quit    ")
    :erlang.halt()
    vm
  end

  def dump(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> dump    ")
    vm
  end

  def words(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> words   ")
    vm
  end

  def tick(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> tick    ")
    vm
  end

  def comma(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> comma   ")
    vm
  end

  def lbrac(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> lbrac   ")
    vm
  end

  def rbrac(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> rbrac   ")
    vm
  end

  def immediate(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> immediate")
    vm
  end

end
