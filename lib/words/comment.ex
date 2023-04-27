defmodule E4vm.Words.Comment do
  def comment(%E4vm{} = vm) do
    case E4vm.read_word(vm) do
      {new_vm, :end} -> new_vm
      {new_vm, ")"} -> new_vm
      {new_vm, _word} -> comment(new_vm)
    end
  end

  def comment_line(%E4vm{} = vm) do
    case E4vm.read_word(vm) do
      {new_vm, :end} -> new_vm
      {new_vm, "\r\n"} -> new_vm
      {new_vm, "\n\r"} -> new_vm
      {new_vm, "\r"} -> new_vm
      {new_vm, "\n"} -> new_vm
      {new_vm, _word} -> comment_line(new_vm)
    end
  end
end
