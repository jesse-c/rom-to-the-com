defmodule RomToTheCom.Repo.Migrations.AddEditsTable do
  use Ecto.Migration

  def change do
    create table(:edits) do
      add :film_id, :string, null: false
      add :romance_percentage, :integer, null: false
      add :comedy_percentage, :integer, null: false

      timestamps()
    end
  end
end
