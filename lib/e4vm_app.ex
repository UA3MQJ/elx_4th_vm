defmodule E4vm.App do
  @behaviour Ratatouille.App

  import Ratatouille.View

  def init(_context), do: 0

  def update(model, msg) do
    case msg do
      {:event, %{ch: ?+}} -> model + 1
      {:event, %{ch: ?-}} -> model - 1
      _ -> model
    end
  end

  def render(model) do
    # view do
    #   label(content: "Counter is #{model} (+/-)")
    # end
    view do
      canvas(height: 10, width: 10) do
        [canvas_cell(x: model+1, y: 1, char: "X")]
      end
    end
  end
end
