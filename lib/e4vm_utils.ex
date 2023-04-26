defmodule E4vm.Utils do
  alias Structure.Stack

  # взять со стека 2 операнда, применить операцию и положить на стек
  def ds2to1op(%E4vm{ds: ds} = vm, f) do
    {:ok, x2} = Stack.head(ds)
    {:ok, next_ds} = Stack.pop(ds)

    {:ok, x1} = Stack.head(next_ds)
    {:ok, next_ds} = Stack.pop(next_ds)

    result = f.(x1, x2)

    next_ds = next_ds |> Stack.push(result)
    %E4vm{vm | ds: next_ds}
  end

  # взять со стека 1 операнда, применить операцию и положить на стек
  def ds1to1op(%E4vm{ds: ds} = vm, f) do
    {:ok, x} = Stack.head(ds)
    {:ok, next_ds} = Stack.pop(ds)

    result = f.(x)

    next_ds = next_ds |> Stack.push(result)
    %E4vm{vm | ds: next_ds}
  end

  def ds_push(%E4vm{} = vm, value) do
    next_ds = vm.ds |> Stack.push(value)
    %E4vm{vm | ds: next_ds}
  end

  def ds_pop(%E4vm{ds: ds} = _vm) do
    {:ok, x} = Stack.head(ds)
    x
  end

  def true_const(%E4vm{cell_bit_size: cell_bit_size} = _vm),
    do: (2 ** cell_bit_size) - 1

end
