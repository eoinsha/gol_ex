defmodule GolSocket do
  def run(topic, socket) do
    loop(socket)
  end

  def loop(socket) do
    receive do
      {:state_change, x, y, alive} ->
        Phoenix.Channel.push socket, "gol:state", {x, y, alive}
      _ -> :ok
    end
    loop(socket)
  end
end
