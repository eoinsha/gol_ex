defmodule GolEx.PageController do
  use GolEx.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
