defmodule Elixirdaze.Post do
  use Elixirdaze.Web, :model

  alias Elixirdaze.{User}

  schema "posts" do
    field :title, :string
    field :body, :string
    field :published_at, Ecto.DateTime

    belongs_to :user, User

    timestamps
  end

  @required_fields ~w(title body)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:title, min: 1)
    |> validate_length(:body, min: 100)
  end
end
