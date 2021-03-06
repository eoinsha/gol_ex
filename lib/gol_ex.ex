defmodule GolEx do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(GolEx.Endpoint, []),
      # Start the Ecto repository
      worker(GolEx.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(GolEx.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GolEx.Supervisor]
    {:ok, state} = Supervisor.start_link(children, opts)
    create_world
    {:ok, state}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GolEx.Endpoint.config_change(changed, removed)
    :ok
  end

  def restart_world do
    Process.unregister(:world)
    create_world
  end

  defp create_world do
    {:ok, world} = Machine.start_link
    Process.register(world, :world)
  end
end
