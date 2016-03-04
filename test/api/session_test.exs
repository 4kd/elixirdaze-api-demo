defmodule ElixirDaze.Api.SessionTest do
  use ElixirDaze.ConnCase
  use EctoFixtures
  use AuthTestSupport
  import Voorhees.JSONApi

  @tag fixtures: [:users]
  test "creating a session succesfully", %{conn: conn, data: %{users: users}} do
    conn
    |> authenticate(email: users.one.email, password: "password")
    |> assert_authorized_as(users.one)
    |> json_response(200)
    |> assert_data(users.one)
  end

  test "unsuccesfully creating a session", %{conn: conn} do
    conn = authenticate(conn, email: "no-exist@example.com", password: "badpassword")
    assert conn.status == 401
  end

  @tag fixtures: [:users]
  test "deleting a session", %{conn: conn, data: %{users: users}} do
    conn =
      conn
      |> authenticate(email: users.one.email, password: "password")
      |> assert_authorized_as(users.one)
      |> delete(session_path(conn, :delete))
      |> refute_authorized_as(users.one)

    assert conn.status == 204
  end
end
