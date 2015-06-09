defmodule Machine do
  use GenServer

  @width 40
  @height 40
  @tick_interval 500

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def handle_info({:state_change, x, y, alive}, state) do
    IO.puts "Sending #{x}.#{y}:#{alive}"
    GolEx.Endpoint.broadcast("world:updates", "gol:state", %{x: x, y: y, alive: alive})
    {:noreply, state}
  end

  def get_world(pid) do
    GenServer.call(pid, :get_world)
  end

  def init(_args) do
    :random.seed(:erlang.now)
    world = create_world(@width, @height)
    init_world(@width, @height, world)
    {:ok, %{}}
  end

  def create_world(w, h) do
    for y <- 0..h-1 do
      for x <- 0..w-1 do
        create_cell(x, y)
      end
    end
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple
  end

  defp find_neighbours(x, y, world) do
    for (i <- x-1..x+1), (j <- y-1..y+1), 
        (i >= 0 and i < @width and j >= 0 and j < @height and (i != x or j != y)) do
      world |> get_cell(i,j)
    end
  end

  defp init_world(w, h, world) do
    for y <- 0..h-1 do
      for x <- 0..w-1 do
        neighbours=find_neighbours(x, y, world) 
        alive = :random.uniform(3) != 1  
        world |> get_cell(x,y) |> init_cell(alive, neighbours)
      end
    end
  end

  defp get_cell(world, x,y) do
      world |> elem(y) |> elem(x)
  end

  defp create_cell(x, y) do
    Cell.start(self, x, y)
  end

  defp init_cell(cell_pid, alive, neighbours) do
    send cell_pid, {:setup, alive, neighbours}
  end
end
