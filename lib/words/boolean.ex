defmodule E4vm.Words.Boolean do
  alias Structure.Stack
  require Logger
  use Bitwise

  def add_core_words(%E4vm{} = vm) do
    vm
    |> E4vm.add_core_word("true",      {E4vm.Words.Boolean, :bool_true},        false)
    |> E4vm.add_core_word("false",     {E4vm.Words.Boolean, :bool_false},       false)
    |> E4vm.add_core_word("and",       {E4vm.Words.Boolean, :bool_and},         false)
    |> E4vm.add_core_word("or",        {E4vm.Words.Boolean, :bool_or},          false)
    |> E4vm.add_core_word("xor",       {E4vm.Words.Boolean, :bool_xor},         false)
    |> E4vm.add_core_word("not",       {E4vm.Words.Boolean, :bool_not},         false)
    |> E4vm.add_core_word("invert",    {E4vm.Words.Boolean, :bool_invert},      false)
    |> E4vm.add_core_word("=",         {E4vm.Words.Boolean, :bool_eql},         false)
    |> E4vm.add_core_word("<>",        {E4vm.Words.Boolean, :bool_not_eql},     false)
    |> E4vm.add_core_word("<",         {E4vm.Words.Boolean, :bool_less},        false)
    |> E4vm.add_core_word(">",         {E4vm.Words.Boolean, :bool_greater},     false)
    |> E4vm.add_core_word("<=",        {E4vm.Words.Boolean, :bool_less_eql},    false)
    |> E4vm.add_core_word(">=",        {E4vm.Words.Boolean, :bool_greater_eql}, false)
  end

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

  def bool_and(%E4vm{} = vm) do
    E4vm.Utils.ds2to1op(vm, fn(x1, x2) ->
      <<y :: integer-unsigned-16>> = <<band(x1, x2) :: integer-signed-16>>
      y
    end)
  end

  def bool_or(%E4vm{} = vm) do
    E4vm.Utils.ds2to1op(vm, fn(x1, x2) ->
      <<y :: integer-unsigned-16>> = <<bor(x1, x2) :: integer-signed-16>>
      y
    end)
  end

  def bool_xor(%E4vm{} = vm) do
    E4vm.Utils.ds2to1op(vm, fn(x1, x2) ->
      <<y :: integer-unsigned-16>> = <<bxor(x1, x2) :: integer-signed-16>>
      y
    end)
  end

  def bool_eql(%E4vm{} = vm) do
    E4vm.Utils.ds2to1op(vm, fn(x1, x2) ->
      E4vm.Utils.to_bool_const(vm, x1 == x2)
    end)
  end

  def bool_not_eql(%E4vm{} = vm) do
    E4vm.Utils.ds2to1op(vm, fn(x1, x2) ->
      E4vm.Utils.to_bool_const(vm, not(x1 == x2))
    end)
  end


  def bool_less(%E4vm{} = vm) do
    E4vm.Utils.ds2to1op(vm, fn(x1, x2) ->
      E4vm.Utils.to_bool_const(vm, (x1 < x2))
    end)
  end

  def bool_greater(%E4vm{} = vm) do
    E4vm.Utils.ds2to1op(vm, fn(x1, x2) ->
      E4vm.Utils.to_bool_const(vm, (x1 > x2))
    end)
  end

  def bool_less_eql(%E4vm{} = vm) do
    E4vm.Utils.ds2to1op(vm, fn(x1, x2) ->
      E4vm.Utils.to_bool_const(vm, (x1 <= x2))
    end)
  end

  def bool_greater_eql(%E4vm{} = vm) do
    E4vm.Utils.ds2to1op(vm, fn(x1, x2) ->
      E4vm.Utils.to_bool_const(vm, (x1 >= x2))
    end)
  end
end
