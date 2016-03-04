defmodule ElixirDaze.Api.SessionTest do
  use ElixirDaze.ConnCase
  use EctoFixtures
  use AuthTestSupport

  @tag fixtures: [:users]
  test "creating a session succesfully", %{conn: conn, data: %{users: users}} do
    payload =
    conn
      |> post(session_path(conn, :create), %{email: users.one.email, password: "password"})
      |> json_response(200)

    expected_payload = %{
      "data" => %{
        "attributes" => %{
          "email" => "one@example.com",
           "name" => "Brian"
          },
         "id" => "#{users.one.id}",
         "type" => "user"
      },
      "jsonapi" => %{"version" => "1.0"}
    }

    assert payload == expected_payload
  end

  test "unsuccesfully creating a session", %{conn: conn} do
    conn = post(conn, session_path(conn, :create), %{email: "no-exist@example.com", password: "badpassword"})
    assert conn.status == 401
  end

  @tag fixtures: [:users]
  test "deleting a session", %{conn: conn, data: %{users: users}} do
    conn =
      conn
      |> post(session_path(conn, :create), %{email: users.one.email, password: "password"})
      |> delete(session_path(conn, :delete))

    assert conn.status == 204
  end
end
