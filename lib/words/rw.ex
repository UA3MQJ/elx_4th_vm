defmodule E4vm.Words.RW do
  alias Structure.Stack
  require Logger

  def add_core_words(%E4vm{} = vm) do
    vm
    |> E4vm.add_core_word(".",         {E4vm.Words.RW, :dot}, false)
    |> E4vm.add_core_word(".s",        {E4vm.Words.RW, :dot_s}, false)
    |> E4vm.add_core_word("cr",        {E4vm.Words.RW, :cr}, false)
    |> E4vm.add_core_word("bl",        {E4vm.Words.RW, :bl}, false)
    |> E4vm.add_core_word("word",      {E4vm.Words.RW, :read_word}, true)
    |> E4vm.add_core_word("s\"",       {E4vm.Words.RW, :read_string}, true)
    |> E4vm.add_core_word("key",       {E4vm.Words.RW, :key}, false)
  end

  def dot(%E4vm{} = vm) do
    {:ok, x} = Stack.head(vm.ds)
    {:ok, next_ds} = Stack.pop(vm.ds)

    IO.write("#{x} ")

    %E4vm{vm | ds: next_ds}
  end

  def dot_s(%E4vm{} = vm) do
    IO.write("<#{length(vm.ds.list)}> ")

    vm.ds.list
    |> :lists.reverse()
    |> Enum.map(fn(x) -> IO.write("#{x} ") end)

    vm
  end

  def cr(%E4vm{} = vm) do
    IO.write("\r\n")
    vm
  end

  def bl(%E4vm{} = vm) do
    IO.write(" ")
    vm
  end

  def key(%E4vm{} = vm) do
    {new_user_char_state, char} = E4vm.user_read_char(vm)
    new_vm = %{vm | user_read_char_state: new_user_char_state}
    case char do
      :end ->
        Logger.error("read_char error: end of char sequence")
        vm
      <<char_number>> ->
        next_ds = new_vm.ds |> Stack.push(char_number)
        %E4vm{new_vm | ds: next_ds}
    end
  end

  def read_word(%E4vm{} = vm) do
    case E4vm.read_word(vm) do
      {_vm, :end} ->
        Logger.error("read_char error: end of char sequence")
        vm
      {new_vm, word} ->
        Logger.info("read_word: #{inspect word}")
        if new_vm.is_eval_mode do
          # DS.Push(str);
                  # next_ds = new_vm.ds |> Stack.push(char_number)
          new_vm
        else
          # AddOp(LookUp("doLit").Address);
          # AddOp(str);
          new_vm
        end
    end
  end

end
