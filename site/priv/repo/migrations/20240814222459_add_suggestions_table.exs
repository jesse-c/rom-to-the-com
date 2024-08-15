defmodule RomToTheCom.Repo.Migrations.AddSuggestionsTable do
  use Ecto.Migration

  def change do
    create table(:suggestions) do
      add :imdb_link, :string
      add :romance_percentage, :integer
      add :comedy_percentage, :integer

      timestamps()
    end
  end
end
