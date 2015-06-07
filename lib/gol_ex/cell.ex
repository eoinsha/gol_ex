defmodule Cell do
  import MultiDef

  @doc """
  Starts a cell process, returning the PID
  """
  def start(x, y) do
    spawn fn -> loop(x, y, false, []) end
  end 

  def loop(x, y, state, neighbours, num_alive \\ 0) do
    receive do
      {:setup, init_state, neighbours} -> 
        loop(x, y, init_state, neighbours, num_alive)
      {:neighbour_state, _neighbour, new_state} -> 
        if new_state do num_alive_now = num_alive + 1 else num_alive_now = num_alive - 1 end
        loop(x, y, get_state(state, num_alive_now), neighbours, num_alive_now)
    end 
  end

  mdef get_state do
    true, neighbours_alive when neighbours_alive == 2 or neighbours_alive == 3 -> true
    true, _ -> false
    false, 3 -> true
    false, _ -> false     
  end
end
