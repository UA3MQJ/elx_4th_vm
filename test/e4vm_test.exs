defmodule E4vmTest do
  use ExUnit.Case
  doctest E4vm

  @next    0
  @do_list 1
  @exit    2
  @hello   3

  test "greets the world" do
    Process.register(self(), :test_proc)

    entry_point = 7

    core = %{
      @next    => {E4vm, :next},
      @do_list => {E4vm, :do_list},
      @exit    => {E4vm, :exit},
      @hello   => {E4vmTest, :hello}
    }

    vm = E4vm.new
    vm2 = %E4vm{vm | ip: 0, wp: entry_point, core: core}
    # |> IO.inspect(label: ">>>>>>>>>>>> befre do_list")
    |> E4vm.do_list()
    # |> IO.inspect(label: ">>>>>>>>>>>> befre next")
    |> E4vm.next()
    # |> IO.inspect(label: ">>>>>>>>>>>> after next")

    assert_receive :hello
  end

  def hello(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>TEST>>>> hello  ")

    IO.puts("Hello")

    send(:test_proc, :hello)

    vm
  end
end
