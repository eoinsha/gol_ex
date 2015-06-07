defmodule Cell do
  import MultiDef

  @doc """
  Starts a cell process, returning the PID
  """
  def start(x, y) do
    spawn fn -> loop(x, y, :dead, %{}) end
  end 

  def loop(x, y, state, neighbours) do
    receive do
      {:state, new_state} -> loop(x, y, new_state, neighbours)
      {:neighbour_change, neighbour, new_state} -> 
        neighbours = %{neighbours | neighbour: new_state}
        num_alive = Map.values(neighbours ) |> Enum.count(fn(value) -> value == :alive end)
        loop(x, y, get_state(state, neighbours), neighbours)
    end 
  end

  mdef get_state do
    :alive, neighbours_alive when neighbours_alive == 2 or neighbours_alive == 3 -> :alive
    :alive, _ -> :dead
    :dead, 3 -> :alive
    :dead, _ -> :dead     
  end
end
