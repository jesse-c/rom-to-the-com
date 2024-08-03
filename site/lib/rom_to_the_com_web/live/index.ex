defmodule RomToTheComWeb.Live.Index do
  use RomToTheComWeb, :live_view

  require Logger

  NimbleCSV.define(MyParser, separator: ",", escape: "\"")

  def mount(_params, _session, socket) do
    Logger.debug("Index lifecycle: :mount_started")

    {:ok, all_films} = load_csv()

    rom = 50
    com = 50
    pos = 50

    {:ok, filtered_films} = filter_films(all_films, rom, com)

    socket =
      assign(socket,
        all_films: all_films,
        filtered_films: filtered_films,
        rom: rom,
        com: com,
        pos: pos
      )

    Logger.debug("Index lifecycle: :mount_finished")

    {:ok, socket}
  end

  def handle_event(
        "slider-update",
        %{"displayRom" => rom, "displayCom" => com, "pos" => pos},
        socket
      ) do
    {:ok, filtered_films} = filter_films(socket.assigns.all_films, rom, com)

    {
      :noreply,
      assign(
        socket,
        filtered_films: filtered_films,
        rom: rom,
        com: com,
        pos: pos
      )
    }
  end

  defp load_csv do
    path = Application.app_dir(:rom_to_the_com, "priv/films.csv")

    with {:ok, content} <- File.read(path),
         parsed_csv <- MyParser.parse_string(content),
         [_headers | rows] <- parsed_csv do
      {:ok, Enum.map(rows, &process_row/1)}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Failed to parse CSV"}
    end
  end

  defp process_row([title, year, rank]) do
    [rom, com] = String.split(rank, "/")

    {year, _rem} = Integer.parse(year)
    {rom, _rem} = Integer.parse(rom)
    {com, _rem} = Integer.parse(com)

    %{
      title: title,
      year: year,
      rank: %{rom: rom, com: com}
    }
  end

  defp filter_films(films, target_rom, target_com) do
    {
      :ok,
      Enum.filter(
        films,
        fn %{rank: %{rom: rom, com: com}} -> rom == target_rom && com == target_com end
      )
    }
  end
end
