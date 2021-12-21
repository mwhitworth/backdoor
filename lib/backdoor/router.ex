defmodule Backdoor.Router do
  @moduledoc """
  Provides LiveView routing for Backdoor.
  """

  @doc """
  Defines a Backdoor route.

  It expects the `path` the backdoor will be mounted at
  and a set of options.

  ## Options

    * `:live_socket_path` - Configures the socket path. it must match
      the `socket "/live", Phoenix.LiveView.Socket` in your endpoint.

  ## Examples

      defmodule MyAppWeb.Router do
        use Phoenix.Router
        import Backdoor.Router

        scope "/", MyAppWeb do
          pipe_through [:browser]
          backdoor "/web_console"
        end
      end

  """
  defmacro backdoor(path, opts \\ []) do
    quote bind_quoted: binding() do
      scope path, alias: false, as: false do
        import Phoenix.LiveView.Router, only: [live: 4, live_session: 3]

        opts = Backdoor.Router.__options__(opts)

        live_session :backdoor, [session: opts[:session], root_layout: opts[:layout]] do
          live "/", Backdoor.BackdoorLive, :backdoor, [private: opts[:private], as: :backdoor]
        end
      end
    end
  end

  @doc false
  def __options__(options) do
    live_socket_path = Keyword.get(options, :live_socket_path, "/live")

    [
      session: {__MODULE__, :__session__, []},
      private: %{live_socket_path: live_socket_path},
      layout: {Backdoor.LayoutView, :dash},
      as: :backdoor
    ]
  end

  @doc false
  def __session__(_conn) do
    %{}
  end
end
