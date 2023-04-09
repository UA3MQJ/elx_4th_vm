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
  alias Structure.Stack

  defstruct mem: %{}, # память программ
            rs: Structure.Stack.new(), # Стек возвратов
            ds: Structure.Stack.new(), # Стек данных
            ip: 0,                     # Указатель инструкций
            wp: 0,                     # Указатель слова
            core: %{},                 # Base instructions
            entries: [],               # Core Word header dictionary
            hereP: 0,                  # Here pointer
            is_eval_mode: true,        #
            read_word_mfa: nil         # {m,f,a}


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
    |> add_core_word("execute",   {E4vm.Words.Core, :execute},        false)
    |> add_core_word(":",         {E4vm.Words.Core, :begin_def_word}, false)
    |> add_core_word(";",         {E4vm.Words.Core, :end_def_word},   true)
    |> add_core_word("branch",    {E4vm.Words.Core, :branch},         false)
    |> add_core_word("0branch",   {E4vm.Words.Core, :zbranch},        false)
    |> add_core_word("dump",      {E4vm.Words.Core, :dump},           false)
    |> add_core_word("words",     {E4vm.Words.Core, :words},          false)
    |> add_core_word("'",         {E4vm.Words.Core, :tick},           false) # TODO deps readword
  end

  def eval(%E4vm{} = vm, string) do
    String.split(string)
    |> Enum.reduce(vm, fn word, vm ->
      IO.inspect(word, label: ">>>> word")

      if vm.is_eval_mode do
        # eval mode
        word_addr = look_up_word_address(vm, word)
        if word_addr != :undefined do
          execute(vm, word_addr)
        else
          IO.inspect(word, label: ">>>> not word")

          if is_constant(word) do
            IO.inspect(word, label: ">>>> is_constant")

            integer = String.to_integer(word)
            next_ds = Stack.push(vm.ds, integer)

            %E4vm{vm | ds: next_ds}
          else

            vm
          end
        end
      else
        # program mode

        vm
      end
    end)
  end


  def execute(vm, word) when is_bitstring(word) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> execute word")

    case look_up_word_address(vm, word) do
      :undefined ->
        IO.puts("The word #{inspect word} is undefined")
        %E4vm{vm| ds: Structure.Stack.new()}
      addr ->
        execute(vm, addr)
    end
  end

  def execute(vm, addr) when is_integer(addr) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> execute addr")

    # try cath какой то надо, наверное
    if addr < vm.entries do
      # слово из core
      {_word, {{m, f}, _immediate, _enable}} = :lists.nth(addr + 1, :lists.reverse(vm.entries))

      apply(m, f, [vm])
    else
      # интерпретируемое слово
      %E4vm{vm | ip: 0, wp: addr}
        |> E4vm.Words.Core.do_list()
        |> E4vm.Words.Core.next()
    end
  end

  def read_word(%E4vm{} = vm) do
    {m, f, a} = vm.read_word_mfa
    apply(m, f, a)
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

  def define(%E4vm{} = vm, word, entry, immediate \\ false) do
    entry = {word, {entry, immediate, true}}
    %E4vm{vm| entries: [entry] ++ vm.entries}
  end

  def add_header(%E4vm{} = vm, word) do
    vm |> E4vm.define(word, vm.hereP)
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

  # поиск адреса слова
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
    "ds: #{inspect(vm.ds, charlists: :as_lists)} rs: #{inspect(vm.rs, charlists: :as_lists)} is_eval_mode: #{inspect vm.is_eval_mode} \r\nMem:"
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

  def is_constant(string) do
    cond do
      is_digit(String.slice(string, 0..0)) ->
        true
      (String.length(string) >= 2) and (String.slice(string, 0..0) in ["+", "-"]) and (is_digit(String.slice(string, 1..1))) ->
        true
      true ->
        false
    end
  end

  def is_digit(char) do
    char in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  end
end
