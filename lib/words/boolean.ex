defmodule E4vm.Words.Boolean do
  alias Structure.Stack
  require Logger
  use Bitwise

  def bool_true(%E4vm{} = vm) do
    # ( -- true )
    # Return a true flag, a single-cell value with all bits set.
    next_ds = vm.ds |> Stack.push(E4vm.Utils.true_const(vm))
    %E4vm{vm | ds: next_ds}
  end

  def bool_false(%E4vm{} = vm) do
    # ( -- false )
    # Return a false flag.
    next_ds = vm.ds |> Stack.push(0)
    %E4vm{vm | ds: next_ds}
  end

  # работает только с логическими значениями, в отличие от invert
  def bool_not(%E4vm{} = vm) do
    true_const = E4vm.Utils.true_const(vm)
    E4vm.Utils.ds1to1op(vm, fn(x) ->
      case x do
        ^true_const -> 0
        0 -> true_const
        _else ->
          Logger.error "Top ds is not logical"
          x
      end
    end)
  end

  def bool_invert(%E4vm{} = vm) do
    E4vm.Utils.ds1to1op(vm, fn(x) ->
      <<y :: integer-unsigned-16>> = <<bnot(x) :: integer-signed-16>>
      y
    end)
  end

  def bool_and(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> x1 - x2 end)

  def bool_or(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> x1 - x2 end)

  def bool_xor(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> x1 - x2 end)

  def bool_eql(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> x1 - x2 end)

  def bool_not_eql(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> x1 - x2 end)

  def bool_less(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> x1 - x2 end)

  def bool_greater(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> x1 - x2 end)

  def bool_less_eql(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> x1 - x2 end)

  def bool_greater_eql(%E4vm{} = vm),
    do: E4vm.Utils.ds2to1op(vm, fn(x1, x2) -> x1 - x2 end)
end
