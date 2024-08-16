defmodule RomToTheComWeb.Live.Index do
  use RomToTheComWeb, :live_view

  alias RomToTheCom.Repo
  alias RomToTheCom.Suggestion

  NimbleCSV.define(MyParser, separator: ",", escape: "\"")

  @poster_base_url "https://image.tmdb.org/t/p/w500/"

  def mount(_params, session, socket) do
    {:ok, all_films} = load_csv()

    rom = 50
    com = 50
    pos = 50

    {:ok, filtered_films} = filter_films(all_films, rom, com)

    socket =
      assign(
        socket,
        all_films: all_films,
        filtered_films: filtered_films,
        rom: rom,
        com: com,
        pos: pos,
        page_title: "Index",
        form:
          to_form(
            Ecto.Changeset.change(%Suggestion{
              romance_percentage: rom,
              comedy_percentage: com
            })
          ),
        details_open: false,
        client_ip: session["client_ip"]
      )

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

  def handle_event("toggle_details", _params, socket) do
    {:noreply, assign(socket, details_open: not socket.assigns.details_open)}
  end

  def handle_event("validate", params, socket) do
    params =
      %{
        imdb_link: params["imdb-link"],
        romance_percentage: params["romance-percentage"],
        comedy_percentage: params["comedy-percentage"]
      }

    form =
      %Suggestion{}
      |> Suggestion.changeset(params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", params, socket) do
    params =
      %{
        imdb_link: params["imdb-link"],
        romance_percentage: params["romance-percentage"],
        comedy_percentage: params["comedy-percentage"]
      }

    changeset =
      %Suggestion{}
      |> Suggestion.changeset(params)
      |> Map.put(:action, :insert)

    cond do
      match?(
        {:deny, _limit},
        Hammer.check_rate("save:#{socket.assigns[:client_ip]}", 60_000, 10)
      ) ->
        socket =
          socket
          |> assign(form: to_form(changeset))
          |> clear_flash()
          |> put_flash(:error, "Try again later!")

        {:noreply, socket}

      changeset.valid? ->
        case Repo.insert(changeset) do
          {:ok, _suggestion} ->
            Req.post!("https://api.pushover.net/1/messages.json",
              json: %{
                token:
                  Application.get_env(:rom_to_the_com, RomToTheComWeb.Pushover)[:pushover_api_key],
                user:
                  Application.get_env(:rom_to_the_com, RomToTheComWeb.Pushover)[
                    :pushover_user_key
                  ],
                message:
                  "Suggestion created! IMDB link: #{Ecto.Changeset.get_field(changeset, :imdb_link)}, romance percentage: #{Ecto.Changeset.get_field(changeset, :romance_percentage)}%, comedy percentage: #{Ecto.Changeset.get_field(changeset, :comedy_percentage)}%"
              }
            )

            {:noreply, put_flash(socket, :info, "Suggestion created!")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      true ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
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

  defp process_row([id, title, year, rank, poster]) do
    [rom, com] = String.split(rank, "/")

    {year, _rem} = Integer.parse(year)
    {rom, _rem} = Integer.parse(rom)
    {com, _rem} = Integer.parse(com)

    %{
      id: id,
      title: title,
      year: year,
      rank: %{rom: rom, com: com},
      poster: poster_to_url(poster)
    }
  end

  defp poster_to_url(poster)
  defp poster_to_url(""), do: nil
  defp poster_to_url(poster), do: Path.join([@poster_base_url, poster])

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
