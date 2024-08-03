defmodule RomToTheCom.Repo do
  use Ecto.Repo,
    otp_app: :rom_to_the_com,
    adapter: Ecto.Adapters.Postgres
end
