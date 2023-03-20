defmodule E4vmTest do
  use ExUnit.Case
  doctest E4vm

  @next    0
  @do_list 1
  @exit    2
  @hello   3

  test "greets the world" do
    Process.register(self(), :test_proc)

    vm = E4vm.new

    primitives = vm.primitives
      |> Map.merge(%{@hello   => {E4vmTest, :hello}})

    mem = %{
      # указатели
      0 => @next,     # 0 адрес 0 команда - next
      1 => @do_list,  # 1 адрес 1 команда - do_list
      2 => @exit,     # 2 адрес 2 команда - exit
      3 => @hello,    # 3 вдрес 3 команда - hello
      # -------------------------------------------
      # program
      4 => @do_list,  # 3) сохраняем адрес интерпретации IP = 9 на стеке возвратов, затем устанавливаем IP = WP + 1 = 5
      5 => @hello,    # 4) выводим на экран сообщение
      6 => @exit,     # 5) выходим из слова, восстанавливаем IP = 9 со стека возвратов
      7 => @do_list,  # 1) точка входа в подпрограмму - выполнить команду по адресу 4
      8 => 4,         # 2) вызов подпрограммы по адресу 4, устанавливаем WP = 4
      9 => @exit
    }

    ip = 0
    entry_point = 7

    # ставим начальный адрес IP=0 чтобы по завершении выполнения
    # и возврату в 0 закончилась работа цикла next() - там выход на 0.
    # ставим wp указатель на слово wp=7 - адрес входа в программу
    %E4vm{vm | ip: ip, wp: entry_point, primitives: primitives, mem: mem}
      |> E4vm.do_list() # выполняем команду начала интерпретации слова, сохраняя IP = 0 на стеке возвратов
      |> E4vm.next()    # запускаем адресный интерпретатор

    assert_receive :hello
  end

  def hello(vm) do
    "ip:#{vm.ip} wp:#{vm.wp}" |> IO.inspect(label: ">>>>TEST>>>> hello  ")

    IO.puts("Hello")

    send(:test_proc, :hello)

    vm
  end
end
