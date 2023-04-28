defmodule E4vm.Words.Core do
  alias Structure.Stack

  def add_core_words(%E4vm{} = vm) do
    vm
    |> E4vm.add_core_word("nop",       {E4vm.Words.Core, :nop},            false)
    |> E4vm.add_core_word("exit",      {E4vm.Words.Core, :exit},           false)
    |> E4vm.add_core_word("quit",      {E4vm.Words.Core, :quit},           false)
    |> E4vm.add_core_word("next",      {E4vm.Words.Core, :next},           false)
    |> E4vm.add_core_word("doList",    {E4vm.Words.Core, :do_list},        false)
    |> E4vm.add_core_word("doLit",     {E4vm.Words.Core, :do_lit},         false)
    |> E4vm.add_core_word("here",      {E4vm.Words.Core, :get_here_addr},  false)
    |> E4vm.add_core_word("[",         {E4vm.Words.Core, :lbrac},          true)
    |> E4vm.add_core_word("]",         {E4vm.Words.Core, :rbrac},          false)
    |> E4vm.add_core_word(",",         {E4vm.Words.Core, :comma},          false)
    |> E4vm.add_core_word("immediate", {E4vm.Words.Core, :immediate},      true)
    |> E4vm.add_core_word("execute",   {E4vm.Words.Core, :execute},        false)
    |> E4vm.add_core_word(":",         {E4vm.Words.Core, :begin_def_word}, false)
    |> E4vm.add_core_word(";",         {E4vm.Words.Core, :end_def_word},   true)
    |> E4vm.add_core_word("branch",    {E4vm.Words.Core, :branch},         false)
    |> E4vm.add_core_word("0branch",   {E4vm.Words.Core, :zbranch},        false)
    |> E4vm.add_core_word("dump",      {E4vm.Words.Core, :dump},           false)
    |> E4vm.add_core_word("words",     {E4vm.Words.Core, :words},          false)
    |> E4vm.add_core_word("'",         {E4vm.Words.Core, :tick},           false)
  end

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

  # выполнить слово по адресу со стека ds - стек данных
  def execute(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> execute ")

    {:ok, top_ds} = Stack.head(vm.ds)
    {:ok, next_ds} = Stack.pop(vm.ds)

    addr = top_ds

    length(vm.entries) |> IO.inspect(label: ">>>>>>>>>>>> execute ")

    if addr < vm.entries do
      # слово из core
      {_word, {{m, f}, _immediate, _enable}} = :lists.nth(addr + 1, :lists.reverse(vm.entries))
      next_vm = %E4vm{vm | ds: next_ds}

      apply(m, f, [next_vm])
    else
      # интерпретируемое слово
      %E4vm{vm | ds: next_ds}
    end

  end

  def begin_def_word(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> begin_def_word ")

    [{word, {addr, immediate, _enabled}}|tail] = vm.entries

    new_entries = [{word, {addr, immediate, false}}] ++ tail

    {next_vm, word} = E4vm.read_word(vm)

    %E4vm{next_vm | entries: new_entries, is_eval_mode: false}
    |> E4vm.add_header(word) # <- add_header должен стоять первым!
    |> E4vm.add_op_from_string("doList")
  end

  def end_def_word(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> end_def_word ")

    [{word, {addr, immediate, _enabled}}|tail] = vm.entries

    new_entries = [{word, {addr, immediate, true}}] ++ tail

    %E4vm{vm | entries: new_entries, is_eval_mode: true}
      |> E4vm.add_op_from_string("exit")
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

  # поместит в стек данных адрес hereP
  def get_here_addr(vm) do
    "ip:#{vm.ip} wp:#{vm.wp} here:#{vm.hereP}" |> IO.inspect(label: ">>>>>>>>>>>> here    ")
    next_ds = Stack.push(vm.ds, vm.hereP)

    %E4vm{vm | ds: next_ds}
  end

  def quit(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> quit    ")
    :erlang.halt()
    # vm
  end

  def dump(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> dump    ")

    {:ok, size} = Stack.head(vm.ds)
    {:ok, next_ds} = Stack.pop(vm.ds)

    {:ok, start_addr} = Stack.head(next_ds)
    {:ok, next_next_ds} = Stack.pop(next_ds)

    IO.puts("\r\n-----  MEMORY DUMP from addr=#{start_addr} size=#{size} -----\r\n")
    Enum.each(start_addr..start_addr+size, fn(addr) ->
      addr_str = addr
        |> Integer.to_string(16)
        |> String.pad_leading(4, "0")
      data_str = case vm.mem[addr] do
        nil -> 'XX'
        data ->
          Integer.to_string(data, 16)
          |> String.pad_leading(2, "0")
      end

      IO.puts("0x#{addr_str}:#{data_str}")
    end)

    %E4vm{vm | ds: next_next_ds}
  end

  def words(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> words   ")

    words = vm.entries
      |> :lists.reverse()
      |> Enum.map(fn({word, {{_, _}, _, _}}) -> word end)
      |> Enum.join(" ")
      |> IO.inspect(label: ">>>>>>>>>>>> vm   ")

    IO.puts("\r\n#{words}\r\n")
    vm
  end

  def tick(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> tick    ")

    case E4vm.read_word(vm) do
      {vm, :end} ->
        IO.inspect(label: ">>>> tick NO WORDS")
        vm
      {new_vm, word} ->
        # IO.inspect(word, label: ">>>> interpreter word")
        word_addr = E4vm.look_up_word_address(new_vm, word)
        # IO.inspect(word_addr, label: ">>>> word_addr")
        next_ds = Stack.push(new_vm.ds, word_addr)
        %E4vm{new_vm | ds: next_ds}
    end
  end

  # Reserve data space for one cell and store w in the space.
  # просто положит в ячейку на hereP++ число из стека
  def comma(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> comma   ")
    # AddOp(DS.Pop());
    {:ok, top_ds}  = Stack.head(vm.ds)
    {:ok, next_ds} = Stack.pop(vm.ds)

    %E4vm{vm | ds: next_ds}
    |> E4vm.add_op(top_ds)
  end

  # войти в eval режим - eval = true
  def lbrac(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> lbrac   ")
    %E4vm{vm | is_eval_mode: true}
  end

  # выйти из eval режима - eval = false
  def rbrac(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> rbrac   ")
    %E4vm{vm | is_eval_mode: false}
  end

  # делаем последнее определенное слово immediate = true
  def immediate(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> immediate")

  # {"hello2", {{E4vmTest, :hello}, false}}
    [{word, {addr, _immediate, enabled}}|tail] = vm.entries

    new_entries = [{word, {addr, true, enabled}}] ++ tail

    %E4vm{vm | entries: new_entries}
  end

end
