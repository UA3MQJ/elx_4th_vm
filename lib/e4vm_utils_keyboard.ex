defmodule E4vm.Utils.Keaboard do
  def read_char do
    alias Ratatouille.{EventManager, Window}
    {:ok, _pid} = Window.start_link()
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())
    run_rcv()
  end

  defp run_rcv() do
    alias Ratatouille.{EventManager, Window}
    receive do
      {:event, %{ch: ch}} ->
        if ch >= 32 do
          :ok = EventManager.stop()
          :ok = Window.close()
          ch
        end
    end
  end
end
