defmodule GolEx.GolChannel do
  use Phoenix.Channel

  def join("world:updates", _, socket) do
    IO.puts("JOIN!")
#    send(self(), :after_join)
    {:ok, socket}
  end

  def join(topic,_,_) do
    IO.puts("JOIN: #{topic}")
  end

  def handle_info(:after_join, socket) do
    spawn(fn() -> GolSocket.run(socket) end)
    {:noreply, socket}
  end
end
