defmodule Cell do
  import MultiDef

  defmodule State do
    defstruct x: nil, y: nil, alive: false, neighbours: nil, iter: 0
  end

  @doc """
  Starts a cell process, returning the PID
  """
  def start(x, y) do
    spawn fn -> loop(%State{x: x, y: y}) end
  end 

  def loop(state) do
    IO.inspect {"CELL", state}
    receive do
      {:setup, alive, neighbours} -> 
        %{state | iter: 1, alive: alive, neighbours: Enum.map(neighbours, fn(cell) -> {cell, nil} end)}
          |> update_state
          |> loop
      {:neighbour_state, neighbour, alive} -> 
        %{state | iter: state.iter + 1, neighbours: %{state.neighbours | alive: alive}} 
          |> step_state
          |> loop
    end 
  end

  defp step_state(state) do
    neighbour_states = 
      state.neighbours |> Map.values |> Enum.reduce([alive: 0, dead: 0, unknown: 0], fn(n, acc) -> 
        case n do
          nil -> acc ++ [unknown: acc[:unknown] + 1]
          true -> acc ++ [alive: acc[:alive] + 1]
          false -> acc ++ [dead: acc[:dead] + 1]
        end 
      end)
    
    if neighbour_states[:unknown] == 0 do # Wait until all neighbours have sent their state
      case {state.alive, neighbour_states[:alive]} do
        {true, num_alive} when num_alive == 2 or num_alive == 3 -> state
        {true, _} -> update_state(%{state | alive: false})
        {false, 3} -> update_state(%{state | alive: true})
        {false, _} -> state 
      end
    else 
      state  
    end
  end

  defp update_state(state) do
    state.neighbours |> Map.keys |> Enum.each fn(neighbour) -> send neighbour, {:neighbour_state, self(), state.alive} end
    state
  end

end
