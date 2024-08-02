defmodule RomToTheComWeb.Live.Index do
  use RomToTheComWeb, :live_view

  NimbleCSV.define(MyParser, separator: ",", escape: "\"")

  def mount(_params, _session, socket) do
    {:ok, films} = load_csv()

    socket = assign(socket, all_films: films, filtered_films: [])

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

    %{
      title: title,
      year: year,
      rank: %{rom: rom, com: com}
    }
  end
end
