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
  ds word size - 16 bit
  """
  require Logger
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
            # channel options
            # read_word_mfa: nil,        # {m,f}
            # read_word_state: nil,
            read_char_mfa: nil,        # {m,f}
            read_char_state: nil,
            cell_bit_size: 16          # cell - 16 bit


  def new() do
    %E4vm{}
    |> E4vm.Words.Core.add_core_words()
    |> E4vm.Words.Mem.add_core_words()
    |> E4vm.Words.Stack.add_core_words()
    |> E4vm.Words.Math.add_core_words()
    |> E4vm.Words.Boolean.add_core_words()
    |> E4vm.Words.Comment.add_core_words()
    |> E4vm.Words.RW.add_core_words()
  end

  def console() do
    IO.puts("elx_4th_vm console\r\nType some forth commands. Type 'bye' to exit.\r\n")
    console(E4vm.new())
  end

  def console(%E4vm{} = vm) do
    input_string = IO.gets(:stdio, "")

    if input_string not in ["bye\n", "bye\r", "bye\r\n"] do
      new_vm = eval(vm, input_string)
      IO.write("ok\r\n")
      console(new_vm)
    else
      :ok
    end
  end

  def eval(%E4vm{} = vm, string) do
    read_char_mfa = {E4vm, :read_string_char_function}
    read_char_state = string

    %E4vm{vm| read_char_mfa: read_char_mfa, read_char_state: read_char_state}
      |> interpreter()
  end

  def interpreter(%E4vm{} = vm) do
    case read_word(vm) do
      {vm, :end} ->
        vm
      {new_vm, word} ->
        # IO.inspect(word, label: ">>>> interpreter word")
        next_vm = interpreter_word(new_vm, word)
        interpreter(next_vm) # interpreter next
    end
  end


  def interpreter_word(%E4vm{} = vm, string) do
    # todo readword!
    String.split(string)
    |> Enum.reduce(vm, fn word, vm ->
      # IO.inspect(word, label: ">>>> word")

      word_addr = look_up_word_address(vm, word)
      # IO.inspect(word_addr, label: ">>>> word_addr")

      if vm.is_eval_mode do
        # eval mode
        cond do
          # если это слово
          word_addr != :undefined ->
            execute(vm, word_addr)
          # иначе, если это число
          is_constant(word) ->
            integer = String.to_integer(word)
            next_ds = Stack.push(vm.ds, integer)
            %E4vm{vm | ds: next_ds}
          # иначе, это ошибка - такого слова нет и это не константа
          true ->
            Logger.error "(1) The word #{word} is undefined"
            %E4vm{vm| ds: Structure.Stack.new()}
        end
      else
        # program mode
        cond do
          # если это слово
          word_addr != :undefined ->
            word_entry = look_up_word_entry(vm, word)
            {_, immediate, _} = word_entry

            if immediate do
              execute(vm, word_addr)
            else
              add_op(vm, word_addr)
            end
          # иначе, если это число
          is_constant(word) ->
            # пишем в память dolit число
            vm
              |> add_op_from_string("doLit")
              |> add_op(String.to_integer(word))
          # иначе, это ошибка - такого слова нет и это не константа
          true ->
            Logger.error "(2) The word #{word} is undefined"
            %E4vm{vm| ds: Structure.Stack.new(), is_eval_mode: true}
        end
      end
    end)
  end


  def execute(vm, word) when is_bitstring(word) do
    # "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> execute word #{inspect word}")

    case look_up_word_address(vm, word) do
      :undefined ->
        IO.puts("The word #{inspect word} is undefined")
        %E4vm{vm| ds: Structure.Stack.new()}
      addr ->
        execute(vm, addr)
    end
  end

  def execute(vm, addr) when is_integer(addr) do
    # # "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> execute addr #{inspect addr}")

    # try cath какой то надо, наверное
    if addr <= Enum.max(Map.keys(vm.core)) do
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

  # def read_word_function(%{read_word_state: read_word_state} = vm) do
  #   # [hd|tail] = vm.read_word_state
  #   # new_vm = %{vm| read_word_state: tail}
  #   # {new_vm, hd}
  #   if String.length(read_word_state) > 0 do
  #     # <<a>> <> rest ="1 22 333"
  #     # if <<a>> in [" ", "\n", "\r", "\t"] do
  #     # else
  #     # end
  #     {vm, :end}
  #   else
  #     {vm, :end}
  #   end

  # end


  # def read_word_from_string(w, tail) do
  #   if String.length(tail) > 0 do
  #     <<ch>> <> rest = tail
  #     # читаем символ. если он пробел, то ищем слово или возвращаем, если уже есть
  #     if <<ch>> in [" ", "\n", "\r", "\t"] do
  #       # если пусто, то еще ничего на считали и продолждаем
  #       if w=="" do
  #         read_word_from_string(w, rest)
  #       # иначе возвращаем слово
  #       else
  #         {w, tail}
  #       end
  #     else
  #     # если символ не пробел - добавляем
  #     read_word_from_string(w <> <<ch>>, rest)
  #     end
  #   else
  #     {w, tail}
  #   end
  # end

  def read_word(%E4vm{} = vm) do
    {_next_vm, _word} = do_read_word("", vm)
  end

  def do_read_word(word, vm) do
    case read_char(vm) do
      {next_vm, :end} ->
        if word == "" do
          {next_vm, :end}
        # иначе возвращаем слово
        else
          {next_vm, word}
        end
      {next_vm, char} ->
        if char in [" ", "\n", "\r", "\t"] do
          # если пусто, то еще ничего на считали и продолждаем
          if word == "" do
            do_read_word(word, next_vm)
          # иначе возвращаем слово
          else
            {next_vm, word}
          end
        else
          # если символ не пробельный - добавляем
          do_read_word(word <> char, next_vm)
        end
    end
  end

  # берет mfa и выполняет. переключаемая логика.
  # read_char_mfa модуль функция, которой передается vm. возврат {new_vm, char}
  # read_char_state использовать для стейта функции чтения. любые данные.
  def read_char(%E4vm{} = vm) do
    {m, f} = vm.read_char_mfa
    {_next_vm, _char} = apply(m, f, [vm])
  end

  def read_string_char_function(vm) do
    case string_char_reader(vm.read_char_state) do
      {:end, _} ->
        {vm, :end}
      {char, next_state} ->
        {%E4vm{vm|read_char_state: next_state}, char}
    end
  end

  def string_char_reader(state) do
    if String.length(state) > 0 do
      <<char>> <> next_state = state
      {<<char>>, next_state} # char это строка, но длиной 1 символ!
    else
      {:end, state}
    end
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

  # поиск свойств слова
  def look_up_word_entry(%E4vm{} = vm, word) do
    case :proplists.get_value(word, vm.entries) do
      :undefined -> :undefined
      word_entry -> word_entry
    end
  end

  # lookup - поиск слова
  def look_up_word(%E4vm{} = vm, word) do
    case look_up_word_entry(vm, word) do
      :undefined -> :undefined
      {{_m, _f} = core_word_mf, _immediate, _enabled} -> core_word_mf
      {addr, _immediate, _enabled} -> {:addr, addr}
    end
  end

  # поиск адреса слова
  def look_up_word_address(%E4vm{} = vm, word) do
    case look_up_word(vm, word) do
      :undefined ->
        :undefined
      {:addr, addr} ->
        addr
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
    # "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> here->wp")
    %E4vm{vm | wp: vm.hereP}
  end

  def here_to_ip(vm) do
    # "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>>>>>>>>> here->ip")
    %E4vm{vm | ip: vm.hereP}
  end

  def inspect_core(%E4vm{} = vm) do
    "Core:\r\n" <>
    # "ip:#{vm.ip} wp:#{vm.wp} hereP:#{vm.hereP}\r\n" <>
    "ds: #{inspect(vm.ds, charlists: :as_lists)} rs: #{inspect(vm.rs, charlists: :as_lists)} is_eval_mode: #{inspect vm.is_eval_mode} \r\nMem:"
    |> IO.puts()

    vm.mem
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(fn(k) ->
      "#{k}:#{vm.mem[k]} (#{inspect vm.core[vm.mem[k]]})" |> IO.puts()
    end)

    vm.entries |> IO.inspect(label: "Entries [{word, {addr, immediate, enabled}}]")

    vm.core |> IO.inspect(label: "core")

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
