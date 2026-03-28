defmodule Mix.Tasks.CheckDuplicatesTest do
  use ExUnit.Case, async: true

  setup do
    Mix.shell(Mix.Shell.Process)
    on_exit(fn -> Mix.shell(Mix.Shell.IO) end)
    :ok
  end

  defp write_csv(path, rows) do
    body =
      Enum.map_join(rows, "\n", fn {id, title, year} -> ~s("#{id}","#{title}","#{year}","1") end)

    File.write!(path, ~s("id","title","year","rank"\n) <> body)
  end

  defp tmp_csv(rows) do
    path = Path.join(System.tmp_dir!(), "films_test_#{System.unique_integer([:positive])}.csv")
    write_csv(path, rows)
    on_exit(fn -> File.rm(path) end)
    path
  end

  test "reports success when no duplicates" do
    path =
      tmp_csv([
        {"uuid-1", "Film A", "2020"},
        {"uuid-2", "Film B", "2021"}
      ])

    Mix.Tasks.CheckDuplicates.run([path])

    assert_received {:mix_shell, :info, ["Checking" <> _]}
    assert_received {:mix_shell, :info, [msg]}
    assert msg =~ "No duplicate UUIDs found"
    assert msg =~ "2 films"
  end

  test "raises when duplicates are found" do
    path =
      tmp_csv([
        {"uuid-1", "Film A", "2020"},
        {"uuid-1", "Film A Again", "2021"},
        {"uuid-2", "Film B", "2022"}
      ])

    assert_raise Mix.Error, ~r/duplicate/i, fn ->
      Mix.Tasks.CheckDuplicates.run([path])
    end
  end

  test "raises when file does not exist" do
    assert_raise Mix.Error, fn ->
      Mix.Tasks.CheckDuplicates.run(["/nonexistent/films.csv"])
    end
  end
end
