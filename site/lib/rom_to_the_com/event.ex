defmodule RomToTheCom.Event do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "events" do
    field :type, Ecto.Enum, values: [:click, :drag, :toggle]
    field :version, :integer
    field :properties, :map

    timestamps()
  end

  def create_changeset(event, attrs) do
    event
    |> cast(attrs, [:type, :version, :properties])
    |> validate_required([:type, :version, :properties])
  end
end
