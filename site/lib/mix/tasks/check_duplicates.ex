defmodule Mix.Tasks.CheckDuplicates do
  @moduledoc """
  Mix task to check for duplicate UUIDs in the films CSV file.

  ## Usage

      mix check_duplicates

  This task will:
  - Load all films from priv/films.csv
  - Check for duplicate UUIDs
  - Exit with error if duplicates are found
  """
  use Mix.Task

  NimbleCSV.define(FilmsParser, separator: ",", escape: "\"")

  @shortdoc "Check for duplicate UUIDs in films.csv"

  @impl Mix.Task
  def run(args) do
    Mix.shell().info("Checking for duplicate UUIDs in films.csv...")

    case load_films(args) do
      {:ok, films} ->
        check_for_duplicates(films)

      {:error, reason} ->
        Mix.raise("Failed to load films: #{inspect(reason)}")
    end
  end

  defp load_films([path | _]), do: load_films_from(path)
  defp load_films([]), do: load_films_from(Application.app_dir(:rom_to_the_com, "priv/films.csv"))

  defp load_films_from(path) do
    case File.read(path) do
      {:ok, content} ->
        films =
          content
          |> FilmsParser.parse_string()
          |> Enum.map(&extract_film_data/1)

        {:ok, films}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp extract_film_data([id, title, year | _]) do
    %{id: id, title: title, year: year}
  end

  defp check_for_duplicates(films) do
    id_groups = Enum.group_by(films, & &1.id)

    duplicates =
      id_groups
      |> Enum.filter(fn {_id, films} -> length(films) > 1 end)

    case duplicates do
      [] ->
        Mix.shell().info(
          "✓ No duplicate UUIDs found. All #{length(films)} films have unique IDs."
        )

      dupes ->
        Mix.shell().error("\n✗ Found #{length(dupes)} duplicate UUID(s):\n")

        Enum.each(dupes, &report_duplicate/1)

        Mix.raise("Found #{length(dupes)} duplicate UUID(s) in films.csv")
    end
  end

  defp report_duplicate({id, dupes}) do
    Mix.shell().error("UUID: #{id} (used #{length(dupes)} times)")
    Enum.each(dupes, fn film -> Mix.shell().error("  - #{film.title} (#{film.year})") end)
    Mix.shell().error("")
  end
end
