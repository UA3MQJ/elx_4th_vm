defmodule E4vm.Words.Stack do
  alias Structure.Stack

  # удалить слово со стека ( x -- )
  def drop(%E4vm{} = vm) do
    {:ok, next_ds} = Stack.pop(vm.ds)

    %E4vm{vm | ds: next_ds}
  end

  # обменять местами ( x1 x2 -- x2 x1 )
  def swap(%E4vm{} = vm) do
    {:ok, x1} = Stack.head(vm.ds)
    {:ok, next_ds} = Stack.pop(vm.ds)

    {:ok, x2} = Stack.head(next_ds)
    {:ok, next_ds} = Stack.pop(next_ds)

    next_ds = next_ds |> Stack.push(x1) |> Stack.push(x2)
    %E4vm{vm | ds: next_ds}
  end

  # дублировать слово на вершине стека ( x -- x x )
  def dup(%E4vm{} = vm) do
    {:ok, x} = Stack.head(vm.ds)
    next_ds = Stack.push(vm.ds, x)
    %E4vm{vm | ds: next_ds}
  end

  # положить копию второго элемента стека на верх стека ( x1 x2 -- x1 x2 x1 )
  def over(%E4vm{} = vm) do
    {:ok, next_ds} = Stack.pop(vm.ds)
    {:ok, x2} = Stack.head(next_ds)
    next_ds = Stack.push(vm.ds, x2)
    %E4vm{vm | ds: next_ds}
  end

  # развернуть три элемента на стеке ( x1 x2 x3 -- x2 x3 x1 )
  def rot(%E4vm{} = vm) do
    {:ok, x3} = Stack.head(vm.ds)
    {:ok, next_ds} = Stack.pop(vm.ds)

    {:ok, x2} = Stack.head(next_ds)
    {:ok, next_ds} = Stack.pop(next_ds)

    {:ok, x1} = Stack.head(next_ds)
    {:ok, next_ds} = Stack.pop(next_ds)

    next_ds = next_ds |> Stack.push(x1) |> Stack.push(x3) |> Stack.push(x2)
    %E4vm{vm | ds: next_ds}
  end

  # развернуть три элемента на стеке в другую сторону ( x1 x2 x3 -- x3 x1 x2 )
  def nrot(%E4vm{} = vm) do
    {:ok, x3} = Stack.head(vm.ds)
    {:ok, next_ds} = Stack.pop(vm.ds)

    {:ok, x2} = Stack.head(next_ds)
    {:ok, next_ds} = Stack.pop(next_ds)

    {:ok, x1} = Stack.head(next_ds)
    {:ok, next_ds} = Stack.pop(next_ds)

    next_ds = next_ds |> Stack.push(x2) |> Stack.push(x1) |> Stack.push(x3)
    %E4vm{vm | ds: next_ds}
  end

end
