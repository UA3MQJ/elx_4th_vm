defmodule E4vm.Words.Math do

  def minus(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> x1 - x2 end)

  def plus(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> x1 + x2 end)

  def multiply(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> x1 * x2 end)

  def devide(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> div(x1, x2) end)

  def mod(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> rem(x1, x2) end)

  def inc(%E4vm{} = vm),
    do: E4vm.Utils.ds1to1op(vm, fn(x) -> x + 1 end)

  def dec(%E4vm{} = vm),
    do: E4vm.Utils.ds1to1op(vm, fn(x) -> x - 1 end)
end
