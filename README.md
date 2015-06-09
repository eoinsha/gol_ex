# GolEx

Concurrent Conway's Game of Life in Elixir - A simple demonstration of Elixir concurrency and Phoenix channels.

 - Uses Phoenix Channels to send individual cell state changes for HTML5 canvas rendering
 - Single Elixir process per cell (2.5K processes by default)
 - Cells communicate their state to their neighbours only

