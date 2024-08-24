defmodule RomToTheCom.Repo.Migrations.AddEventsTable do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :type, :string, null: false
      add :version, :integer, null: false
      add :properties, :map, null: false

      timestamps()
    end
  end
end
