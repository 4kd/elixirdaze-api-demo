defmodule Elixirdaze.Strategies.AuthorizationTest do
  use Elixirdaze.ConnCase
  use EctoFixtures

  alias Elixirdaze.{Strategies.Authorization, Router, User}

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Router, [:api])
      |> get("/")

    {:ok, conn: conn}
  end

  test "attempting to authorize when no account_id is present sets status to 401 and halts", %{conn: conn} do
    conn = Authorization.call(conn)

    assert conn.status == 401
    assert conn.halted
  end

  test "attempting to authorize when no account_type is present sets status to 401 and halts", %{conn: conn} do
    conn =
      conn
      |> put_session(:account_id, 1)
      |> Authorization.call()

    assert conn.status == 401
    assert conn.halted
  end

  test "attempting to find an account when no account record present sets stauts to 401 and halts", %{conn: conn} do
    conn =
      conn
      |> put_session(:account_id, 1)
      |> put_session(:account_type, User)
      |> Authorization.call()

    assert conn.status == 401
    assert conn.halted
  end

  @tag fixtures: [:users]
  test "will properly authorize an account with valid account_id and account_type", %{conn: conn, data: %{users: users}} do
    conn =
      conn
      |> put_session(:account_id, users.one.id)
      |> put_session(:account_type, User)
      |> Authorization.call()

    assert conn.assigns[:account] == users.one

    refute conn.status == 401
    refute conn.halted
  end

  @tag fixtures: [:users]
  test "will return 401 and halt when attempting to authorize an account not authorized for admin", %{conn: conn, data: %{users: users}} do
    conn =
      conn
      |> put_session(:account_id, users.one.id)
      |> put_session(:account_type, User)
      |> Authorization.call(true)

    assert conn.status == 401
    assert conn.halted
  end

  test "will bypass if account is already assigned", %{conn: conn} do
    account = %{}

    conn =
      conn
      |> assign(:account, account)
      |> Authorization.call()

    refute conn.status == 401
    refute conn.halted
  end

  test "will bypass if account is already assigned as an admin and admin access is requested", %{conn: conn} do
    account = %{admin: true}

    conn =
      conn
      |> assign(:account, account)
      |> Authorization.call()

    refute conn.status == 401
    refute conn.halted
  end

  test "if account is already assigned by attempting to authorize on admin will set status to 401 and halt", %{conn: conn} do
    account = %{}

    conn =
      conn
      |> assign(:account, account)
      |> Authorization.call(true)

    assert conn.status == 401
    assert conn.halted
  end
end
