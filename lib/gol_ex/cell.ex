defmodule Cell do
  import MultiDef

  @doc """
  Starts a cell process, returning the PID
  """
  def start(x, y) do
    spawn fn -> loop(0, x, y, false, []) end
  end 

  def loop(iteration, x, y, state, neighbours, num_alive \\ 0) do
    IO.inspect {iteration, "CELL", x, y, state}
    receive do
      {:setup, init_state, neighbours} -> 
        update_state(neighbours, init_state)
        loop(iteration + 1, x, y, init_state, neighbours, num_alive)
      {:neighbour_state, _neighbour, state} -> 
        if state do num_alive_now = num_alive + 1 else num_alive_now = num_alive - 1 end
        loop(iteration + 1, x, y, step_state(state, num_alive_now, neighbours), neighbours, num_alive_now)
    end 
  end

  mdef step_state do
    true, neighbours_alive, _ when neighbours_alive == 2 or neighbours_alive == 3 -> true
    true, _, neighbours -> update_state(neighbours, false)
    false, 3, neighbours -> update_state(neighbours, true) 
    false, _, _ -> false     
  end

  defp update_state(neighbours, new_state) do
    neighbours |> Enum.each fn(neighbour) -> send neighbour, {:neighbour_state, self(), new_state} end
    new_state
  end

end
