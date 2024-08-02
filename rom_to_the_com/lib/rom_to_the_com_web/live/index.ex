defmodule RomToTheComWeb.Live.Index do
  use RomToTheComWeb, :live_view

  NimbleCSV.define(MyParser, separator: ",", escape: "\"")

  def mount(_params, _session, socket) do
    {:ok, all_films} = load_csv()

    {:ok, filtered_films} = filter_films(all_films, 50, 50)

    socket = assign(socket, all_films: all_films, filtered_films: filtered_films)

    {:ok, socket}
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
