defmodule RomToTheComWeb.HealthControllerTest do
  use RomToTheComWeb.ConnCase

  test "GET /healthz returns OK", %{conn: conn} do
    conn = get(conn, ~p"/healthz")
    assert text_response(conn, 200) == "OK"
  end
end
