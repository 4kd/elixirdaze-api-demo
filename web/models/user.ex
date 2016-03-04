defmodule Elixirdaze.User do
  use Elixirdaze.Web, :model
  import Comeonin.Bcrypt

  alias Elixirdaze.{Post}

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_many :posts, Post

    timestamps
  end

  @required_fields ~w(name email password)
  @optional_fields ~w(password_confirmation)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 1)
    |> validate_length(:password, min: 7)
    |> validate_confirmation(:password)
    |> encrypt_password()
  end

  defp encrypt_password(changeset) do
    if changeset.valid? do
      changeset
      |> put_change(:password_hash, hashpwsalt(changeset.changes.password))
    else
      changeset
    end
  end
end
