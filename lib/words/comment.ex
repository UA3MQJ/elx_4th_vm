defmodule E4vm.Words.Comment do
  def add_core_words(%E4vm{} = vm) do
    vm
    |> E4vm.add_core_word("(",         {E4vm.Words.Comment, :comment},      true)
    |> E4vm.add_core_word("\\\\",      {E4vm.Words.Comment, :comment_line}, true)
  end

  def comment(%E4vm{} = vm) do
    case E4vm.read_word(vm) do
      {new_vm, :end} -> new_vm
      {new_vm, ")"} -> new_vm
      {new_vm, _word} -> comment(new_vm)
    end
  end

  def comment_line(%E4vm{} = vm) do
    {new_char_state, char} = E4vm.read_char(vm)
    new_vm = %{vm | read_char_state: new_char_state}
    case char do
      :end -> new_vm
      "\r" -> new_vm
      "\n" -> new_vm
      _word -> comment_line(new_vm)
    end
  end
end
