defmodule E4vm.Words.RWTest do
  use ExUnit.Case
  import Mock

  test "test ." do
    vm = E4vm.new()

    assert ExUnit.CaptureIO.capture_io(fn ->
      vm |> E4vm.eval("10 .")
    end) == "10 "

    assert ExUnit.CaptureIO.capture_io(fn ->
      vm |> E4vm.eval("20 30 . .")
    end) == "30 20 "
  end

  test "test .s" do
    vm = E4vm.new()

    assert ExUnit.CaptureIO.capture_io(fn ->
      vm |> E4vm.eval("1 2 3 .s")
    end) == "<3> 1 2 3 "
  end

  test "test cr" do
    vm = E4vm.new()

    assert ExUnit.CaptureIO.capture_io(fn ->
      vm |> E4vm.eval("cr")
    end) == "\r\n"
  end

  test "test bl" do
    vm = E4vm.new()

    assert ExUnit.CaptureIO.capture_io(fn ->
      vm |> E4vm.eval("bl")
    end) == " "
  end

  test "test word" do
    vm = E4vm.new()
  end

  test "test s\"" do
    vm = E4vm.new()
  end

  test "test key" do
    vm = E4vm.new()

    with_mocks([
        {E4vm.Utils.Keaboard, [],
        [
        read_char: fn  ->
            13
          end
        ]}
      ]) do
      assert vm |> E4vm.eval("key") |> E4vm.Utils.ds_pop() == 13
    end
  end

end
