defmodule Machine do
  use GenServer

  @width 10
  @height 10
  @tick_interval 500

  def start do
    {:ok, pid} = GenServer.start(__MODULE__, [])
    :timer.send_interval(@tick_interval, pid, :tick)
    {:ok, pid}
  end

  def get_world(pid) do
    GenServer.call(pid, :get_world)
  end

  def init(_args) do
    :random.seed(:erlang.now)
    world = create_world(@width, @height)
    init_world(@width, @height, world)
    {:ok, true}
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
        alive = :random.uniform(2) == 2  
        world |> get_cell(x,y) |> init_cell(alive, neighbours)
      end
    end
  end

  defp get_cell(world, x,y) do
      world |> elem(y) |> elem(x)
  end

  defp create_cell(x, y) do
    Cell.start(x, y)
  end

  defp init_cell(cell_pid, alive, neighbours) do
    send cell_pid, {:setup, alive, neighbours}
  end
end
