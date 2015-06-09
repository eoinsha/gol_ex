defmodule GolSocket do
  def run(world, socket) do
    loop(world, socket)
  end

  def loop(world, socket) do
    receive do
      {:state_change, x, y, alive} ->
        Phoenix.Channel.push socket, "gol:state", {x, y, alive}
      _ -> :ok
    end
    loop(world, socket)
  end
end
