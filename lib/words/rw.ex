defmodule E4vm.Words.RW do
  alias Structure.Stack

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
    read_char = E4vm.Utils.Keaboard.read_char()
    next_ds = vm.ds |> Stack.push(read_char)
    %E4vm{vm | ds: next_ds}
  end

end
