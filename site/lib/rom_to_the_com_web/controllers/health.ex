defmodule RomToTheComWeb.HealthController do
  use RomToTheComWeb, :controller

  def healthz(conn, _params) do
    conn
    |> put_status(200)
    |> text("OK")
  end
end
