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

  def false_const(_vm),
    do: 0

  def to_bool_const(vm, true),  do: true_const(vm)
  def to_bool_const(vm, false), do: false_const(vm)

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
end
