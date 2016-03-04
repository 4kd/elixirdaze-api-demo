defmodule Elixirdaze.UserTest do
  use Elixirdaze.ModelCase
  import ValidField
  import Comeonin.Bcrypt

  alias Elixirdaze.User

  test "validations" do
    %User{}
    |> with_changeset()
    |> assert_field(:email, ["test@example.com"], [nil, "", "foobar"])
    |> assert_field(:name, ["Brian"], [nil, ""])
    |> assert_field(:password, ["password1"], [nil, "asdfas"])


    %User{}
    |> with_changeset(&User.changeset/2)
    |> put_params(%{password: "password"})
    |> assert_invalid_field(:password_confirmation, ["password2"])
  end

  test "will encrypt password if changeset is valid" do
    changeset =
      %User{}
      |> User.changeset(%{email: "test@example.com", name: "Foo", password: "password", password_confirmation: "password"})

    assert checkpw("password", changeset.changes.password_hash)
  end

  test "will not encrypt password if changeset is not valid" do
    changeset =
      %User{}
      |> User.changeset(%{email: "test@example.com", name: "Foo", password: "password", password_confirmation: "barpassword"})

    assert is_nil(changeset.changes[:password_hash])
  end
end
