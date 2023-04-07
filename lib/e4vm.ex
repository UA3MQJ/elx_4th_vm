defmodule WordHeader do
  # addres адрес
  # immediate дает указание интерпретатору, что слово должно быть
  # выполнено в режиме программирования, а не записано в память
  defstruct address: 0,
            immediate: false, # флаг немедленной интерпретации.
            is_enable: true  # слово включено ?
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
            hereP: 0,                  # Here pointer
            is_eval_mode: true         #


  def new() do

    %E4vm{}
    # core
    |> add_core_word("nop",       {E4vm.Words.Core, :nop},            false)
    |> add_core_word("exit",      {E4vm.Words.Core, :exit},           false)
    |> add_core_word("quit",      {E4vm.Words.Core, :quit},           false)
    |> add_core_word("next",      {E4vm.Words.Core, :next},           false)
    |> add_core_word("doList",    {E4vm.Words.Core, :do_list},        false)
    |> add_core_word("doLit",     {E4vm.Words.Core, :do_lit},         false)
    |> add_core_word("here",      {E4vm.Words.Core, :get_here_addr},  false)
    |> add_core_word("[",         {E4vm.Words.Core, :lbrac},          true)
    |> add_core_word("]",         {E4vm.Words.Core, :rbrac},          false)
    |> add_core_word(",",         {E4vm.Words.Core, :comma},          false)
    |> add_core_word("immediate", {E4vm.Words.Core, :immediate},      true)
    |> add_core_word("execute",   {E4vm.Words.Core, :execute},        false) # TODO
    |> add_core_word(":",         {E4vm.Words.Core, :begin_def_word}, false) # TODO deps readword
    |> add_core_word(";",         {E4vm.Words.Core, :end_def_word},   true)
    |> add_core_word("branch",    {E4vm.Words.Core, :branch},         false)
    |> add_core_word("0branch",   {E4vm.Words.Core, :zbranch},        false)
    |> add_core_word("dump",      {E4vm.Words.Core, :dump},           false)
    |> add_core_word("words",     {E4vm.Words.Core, :words},          false)
    |> add_core_word("'",         {E4vm.Words.Core, :tick},           false) # TODO deps readword
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
    entry = {word, {entry, immediate, true}}
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
      {{_m, _f} = word, _immediate, _enabled} -> word
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

  # сохранить текущее here в wp чтобы это место считать стартовым для программы
  def here_to_wp(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> here->wp")
    %E4vm{vm | wp: vm.hereP}
  end

  def here_to_ip(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> here->ip")
    %E4vm{vm | ip: vm.hereP}
  end

  def inspect_core(%E4vm{} = vm) do
    "Core:\r\n" <>
    "ip:#{vm.ip} wp:#{vm.wp} hereP:#{vm.hereP}\r\n" <>
    "ds: #{inspect vm.ds} rs: #{inspect vm.rs} is_eval_mode: #{inspect vm.is_eval_mode} \r\nMem:"
    |> IO.puts()

    vm.mem
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(fn(k) ->
      "#{k}:#{vm.mem[k]} (#{inspect vm.core[vm.mem[k]]})" |> IO.puts()
    end)

    vm.entries |> IO.inspect(label: "Entries")

    vm
  end
end
