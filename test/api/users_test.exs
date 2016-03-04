defmodule ElixirDaze.Api.UsersTest do
  use ElixirDaze.ConnCase
  import ElixirDaze.JsonFor
  import Voorhees.JSONApi

  alias ElixirDaze.{Repo, User}

  test "creating a new user succesfully", %{conn: conn} do
    count = Repo.all(User) |> length()

    data = %{
      name: "brian",
      email: "user@example.com",
      password: "password",
      "password-confirmation": "password"
    }

    conn = post(conn, user_path(conn, :create), json_for(:user, data))

    users = Repo.all(User)
    user = List.last(users)

    conn
    |> json_response(201)
    |> assert_data(user)

    assert count + 1 == length(users)
  end

  test "attempting to create a user unsuccefully", %{conn: conn} do
    count = Repo.all(User) |> length()

    data = %{
      name: "brian",
      email: "user@example.com",
      password: "password",
      "password-confirmation": "badpassword"
    }

    conn = post(conn, user_path(conn, :create), json_for(:user, data))

    assert conn.status == 422
    assert count == Repo.all(User) |> length()
  end
end
