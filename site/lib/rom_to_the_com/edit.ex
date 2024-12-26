defmodule RomToTheCom.Edit do
  use Ecto.Schema

  import Ecto.Changeset

  schema "edits" do
    field :film_id, :string
    field :romance_percentage, :integer
    field :comedy_percentage, :integer

    timestamps()
  end

  def create_changeset(edit, attrs) do
    edit
    |> cast(attrs, [:film_id, :romance_percentage, :comedy_percentage])
    |> validate_required([:romance_percentage, :comedy_percentage])
    |> validate_number(:romance_percentage,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 99
    )
    |> validate_number(:comedy_percentage, greater_than_or_equal_to: 1, less_than_or_equal_to: 99)
    |> validate_rankings_sum()
  end

  defp validate_rankings_sum(changeset) do
    with {_source, romance_percentage} <- fetch_field(changeset, :romance_percentage),
         {_source, comedy_percentage} <- fetch_field(changeset, :comedy_percentage),
         false <- is_nil(romance_percentage),
         false <- is_nil(comedy_percentage),
         true <- is_integer(romance_percentage),
         true <- is_integer(comedy_percentage) do
      if romance_percentage + comedy_percentage != 100 do
        add_error(changeset, :rankings_sum, "Romance and comedy rankings must add up to 100")
      else
        changeset
      end
    else
      _ -> changeset
    end
  end
end