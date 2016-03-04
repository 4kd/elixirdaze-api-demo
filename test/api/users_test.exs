defmodule ElixirDaze.Api.UsersTest do
  use ElixirDaze.ConnCase

  alias ElixirDaze.{Repo, User}

  test "creating a new user succesfully", %{conn: conn} do
    count = Repo.all(User) |> length()

    data = %{
      "data" => %{
        "type" => "user",
        "attributes" => %{
          name: "Brian",
          email: "user@example.com",
          password: "password",
          "password-confirmation": "password"
        }
      }
    }

    conn = post(conn, user_path(conn, :create), data)

    users = Repo.all(User)
    user = List.last(users)

    payload = json_response(conn, 201)

    expected_payload = %{
      "data" => %{
        "attributes" => %{
          "email" => "user@example.com",
           "name" => "Brian"
          },
         "id" => "#{user.id}",
         "type" => "user"
      },
      "jsonapi" => %{"version" => "1.0"}
    }

    assert payload == expected_payload

    assert count + 1 == length(users)
  end

  test "attempting to create a user unsuccefully", %{conn: conn} do
    count = Repo.all(User) |> length()

    data = %{
      "data" => %{
        "type" => "user",
        "attributes" => %{
          name: "Brian",
          email: "user@example.com",
          password: "password",
          "password-confirmation": "badpassword"
        }
      }
    }

    conn = post(conn, user_path(conn, :create), data)

    assert conn.status == 422
    assert count == Repo.all(User) |> length()
  end
end
