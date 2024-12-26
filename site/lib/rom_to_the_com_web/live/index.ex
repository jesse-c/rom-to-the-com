defmodule RomToTheComWeb.Live.Index do
  @moduledoc false
  use RomToTheComWeb, :live_view

  alias RomToTheCom.Repo
  alias RomToTheCom.Suggestion
  alias RomToTheCom.Event
  alias RomToTheCom.Edit

  NimbleCSV.define(MyParser, separator: ",", escape: "\"")

  @poster_base_url "https://image.tmdb.org/t/p/w500/"
  @default_rom 50
  @default_com 50
  @default_pos 50

  def mount(_params, session, socket) do
    {:ok, all_films} = load_csv()

    rom = @default_rom
    com = @default_com
    pos = @default_pos

    search = ""

    {:ok, filtered_films} = filter_films(all_films, rom, com, search)

    socket =
      assign(
        socket,
        all_films: all_films,
        filtered_films: filtered_films,
        rom: rom,
        com: com,
        pos: pos,
        search: search,
        page_title: "Index",
        suggestion:
          to_form(
            Ecto.Changeset.change(%Suggestion{
              romance_percentage: rom,
              comedy_percentage: com
            })
          ),
        edit: nil,
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
    {:ok, filtered_films} =
      filter_films(socket.assigns.all_films, rom, com, socket.assigns.search)

    Task.Supervisor.start_child(MyTaskSupervisor, fn ->
      params = %{
        type: :drag,
        version: 1,
        properties: %{
          element: :slider_drag,
          rom: rom,
          com: com
        }
      }

      %Event{}
      |> Event.create_changeset(params)
      |> case do
        %Ecto.Changeset{valid?: true} = changeset ->
          Repo.insert(changeset)

        %Ecto.Changeset{valid?: false} = changeset ->
          {:error, changeset}
      end
    end)

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

  def handle_event("feeling_lucky", _params, socket) do
    rom = generate_random_percentage()
    com = 100 - rom
    pos = rom

    {:ok, filtered_films} =
      filter_films(socket.assigns.all_films, rom, com, socket.assigns.search)

    Task.Supervisor.start_child(MyTaskSupervisor, fn ->
      params = %{
        type: :click,
        version: 1,
        properties: %{
          element: :im_feeling_lucky_button,
          rom: rom,
          com: com
        }
      }

      %Event{}
      |> Event.create_changeset(params)
      |> case do
        %Ecto.Changeset{valid?: true} = changeset ->
          Repo.insert(changeset)

        %Ecto.Changeset{valid?: false} = changeset ->
          {:error, changeset}
      end
    end)

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

  def handle_event("suggestion_validate", params, socket) do
    params =
      %{
        imdb_link: params["imdb-link"],
        romance_percentage: params["romance-percentage"],
        comedy_percentage: params["comedy-percentage"]
      }

    suggestion =
      %Suggestion{}
      |> Suggestion.create_changeset(params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, suggestion: suggestion)}
  end

  def handle_event("suggestion_save", params, socket) do
    params =
      %{
        imdb_link: params["imdb-link"],
        romance_percentage: params["romance-percentage"],
        comedy_percentage: params["comedy-percentage"]
      }

    changeset =
      %Suggestion{}
      |> Suggestion.create_changeset(params)
      |> Map.put(:action, :insert)

    cond do
      match?(
        {:deny, _limit},
        Hammer.check_rate("suggestion_save:#{socket.assigns[:client_ip]}", 60_000, 10)
      ) ->
        socket =
          socket
          |> assign(suggestion: to_form(changeset))
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
                  "Suggestion submitted! IMDB link: #{Ecto.Changeset.get_field(changeset, :imdb_link)}, romance percentage: #{Ecto.Changeset.get_field(changeset, :romance_percentage)}%, comedy percentage: #{Ecto.Changeset.get_field(changeset, :comedy_percentage)}%"
              }
            )

            socket =
              socket
              |> put_flash(:info, "Suggestion submitted!")
              |> assign(
                suggestion:
                  to_form(
                    Ecto.Changeset.change(%Suggestion{
                      romance_percentage: @default_rom,
                      comedy_percentage: @default_com
                    })
                  ),
                details_open: false
              )

            {:noreply, socket}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, suggestion: to_form(changeset))}
        end

      true ->
        {:noreply, assign(socket, suggestion: to_form(changeset))}
    end
  end

  def handle_event("edit_open", params, socket) do
    id = params["value"]

    if String.trim(id) == "", do: raise("received an empty film id")

    film = Enum.find(socket.assigns.all_films, &(&1.id == id))

    form =
      to_form(
        Ecto.Changeset.change(%Edit{
          romance_percentage: film.rank.rom,
          comedy_percentage: film.rank.com
        })
      )

    {
      :noreply,
      assign(
        socket,
        edit: %{
          film: film,
          form: form
        }
      )
    }
  end

  def handle_event("edit_save", params, socket) do
    film = socket.assigns.edit.film

    params =
      %{
        film_id: film.id,
        romance_percentage: params["romance-percentage"],
        comedy_percentage: params["comedy-percentage"]
      }

    changeset =
      %Edit{}
      |> Edit.create_changeset(params)
      |> Map.put(:action, :insert)

    cond do
      match?(
        {:deny, _limit},
        Hammer.check_rate("edit_save:#{socket.assigns[:client_ip]}", 60_000, 10)
      ) ->
        socket =
          socket
          |> assign(socket, edit: %{film: film, form: to_form(changeset)})
          |> clear_flash()
          |> put_flash(:error, "Try again later!")

        {:noreply, socket}

      changeset.valid? ->
        case Repo.insert(changeset) do
          {:ok, _edit} ->
            Req.post!("https://api.pushover.net/1/messages.json",
              json: %{
                token:
                  Application.get_env(:rom_to_the_com, RomToTheComWeb.Pushover)[:pushover_api_key],
                user:
                  Application.get_env(:rom_to_the_com, RomToTheComWeb.Pushover)[
                    :pushover_user_key
                  ],
                message:
                  "Edit submitted! Title: #{socket.assigns.edit.film.title}, romance percentage: #{socket.assigns.edit.film.rank.rom} → #{Ecto.Changeset.get_field(changeset, :romance_percentage)}%, comedy percentage: #{socket.assigns.edit.film.rank.com} → #{Ecto.Changeset.get_field(changeset, :comedy_percentage)}%"
              }
            )

            socket =
              socket
              |> put_flash(:info, "Edit submitted!")
              |> assign(edit: nil)

            {:noreply, socket}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, edit: %{film: film, form: to_form(changeset)})}
        end

      true ->
        {:noreply, assign(socket, edit: %{film: film, form: to_form(changeset)})}
    end
  end

  def handle_event("edit_validate", params, socket) do
    params =
      %{
        romance_percentage: params["romance-percentage"],
        comedy_percentage: params["comedy-percentage"]
      }

    form =
      %Edit{}
      |> Edit.create_changeset(params)
      |> to_form(action: :validate)

    {:noreply,
     assign(socket,
       edit: %{
         film: socket.assigns.edit.film,
         form: form
       }
     )}
  end

  def handle_event("edit_reset", _params, socket) do
    form =
      to_form(
        Ecto.Changeset.change(%Edit{
          romance_percentage: socket.assigns.edit.film.rank.rom,
          comedy_percentage: socket.assigns.edit.film.rank.com
        })
      )

    {
      :noreply,
      assign(
        socket,
        edit: %{
          film: socket.assigns.edit.film,
          form: form
        }
      )
    }
  end

  def handle_event("edit_cancel", _params, socket) do
    {
      :noreply,
      assign(
        socket,
        edit: nil
      )
    }
  end

  def handle_event("search", %{"search" => search}, socket) do
    {:ok, filtered_films} =
      filter_films(socket.assigns.all_films, socket.assigns.rom, socket.assigns.com, search)

    {:noreply, assign(socket, filtered_films: filtered_films, search: search)}
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

  defp filter_films(films, target_rom, target_com, search)

  defp filter_films(films, target_rom, target_com, "") do
    {
      :ok,
      Enum.filter(films, fn %{rank: %{rom: rom, com: com}} ->
        rom == target_rom && com == target_com
      end)
    }
  end

  defp filter_films(films, _target_rom, _target_com, search) do
    {
      :ok,
      Enum.filter(films, fn %{title: title} ->
        title
        |> String.downcase()
        |> String.contains?(String.downcase(search))
      end)
    }
  end

  defp generate_random_percentage do
    case Enum.random(1..20) do
      1 -> 1
      20 -> 99
      n -> n * 5
    end
  end
end
