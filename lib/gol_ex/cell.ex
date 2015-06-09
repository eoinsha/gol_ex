defmodule Cell do
  import MultiDef

  defmodule State do
    defstruct x: nil, y: nil, alive: false, neighbours: %{}, iter: 0
  end

  @doc """
  Starts a cell process, returning the PID
  """
  def start(parent, x, y) do
    spawn_link fn -> loop(%State{x: x, y: y}, parent) end
  end 

  def loop(state, parent) do
    receive do
      {:setup, alive, neighbours} -> 
        %{state | iter: 1, alive: alive, neighbours: Enum.map(neighbours, fn(cell) -> {cell, nil} end) |> Enum.into %{}}
          |> update_state(parent)
          |> loop(parent)
      {:neighbour_state, neighbour, alive} -> 
        %{state | iter: state.iter + 1, neighbours: Map.put(state.neighbours, neighbour, alive)} 
          |> step_state(parent)
          |> loop(parent)
    end 
  end

  defp step_state(state, parent) do
    neighbour_states = 
      state.neighbours |> Map.values |> Enum.reduce([alive: 0, dead: 0, unknown: 0], fn(n, acc) -> 
        case n do
          nil -> Keyword.put(acc, :unknown, acc[:unknown] + 1)
          true -> Keyword.put(acc, :alive, acc[:alive] + 1)
          false -> Keyword.put(acc, :dead, acc[:dead] + 1)
        end 
      end)

    if neighbour_states[:unknown] == 0 do # Wait until all neighbours have sent their state
      case {state.alive, neighbour_states[:alive]} do
        {true, num_alive} when num_alive == 2 or num_alive == 3 -> state
        {true, _} -> update_state(%{state | alive: false}, parent)
        {false, 3} -> update_state(%{state | alive: true}, parent)
        {false, _} -> state 
      end
    else 
      state  
    end
  end

  defp update_state(state, parent) do
    send parent, {:state_change, state.x, state.y, state.alive}
    state.neighbours |> Map.keys |> Enum.each fn(neighbour) -> 
      send neighbour, {:neighbour_state, self(), state.alive} end
      :timer.sleep(2000)
    state
  end

end
