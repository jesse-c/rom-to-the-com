defmodule RomToTheComWeb.Router do
  use RomToTheComWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RomToTheComWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_ip_to_session
  end

  # session: %{"_csrf_token" => "5CjLB4-ZT3EVDWTV-0b91AJa", "client_ip" => "127.0.0.1"}
  def assign_ip_to_session(conn, _opts) do
    ip_address = conn.remote_ip |> :inet.ntoa() |> to_string()

    Plug.Conn.put_session(conn, :client_ip, ip_address)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RomToTheComWeb do
    pipe_through(:browser)

    live_session :default do
      live("/", Live.Index)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", RomToTheComWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:rom_to_the_com, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RomToTheComWeb.Telemetry
    end
  end
end
