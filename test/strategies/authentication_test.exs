defmodule Elixirdaze.Strategies.AuthenticationTest do
  use Elixirdaze.ConnCase
  use EctoFixtures
  import Comeonin.Bcrypt
  import AuthTestSupport, only: [assert_authorized_as: 2]

  alias Elixirdaze.{Repo, User, Strategies.Authentication}

  defmodule PasswordRepo do
    def one(_),
      do: %{password_hash: hashpwsalt("working-password")}
  end

  setup do
    {:ok, conn: Phoenix.ConnTest.conn() }
  end

  test "returns `{:unauthorized, message}` when querying for non-existing record", %{conn: conn} do
    {:unauthorized, "record not found"} = Authentication.call(conn, User, Repo, %{"email" => "no-exist@example.com", "password" => "password"})
  end

  test "returns `{:unauthornized, message}` if the password check fails", %{conn: conn} do
    {:unauthorized, "token check failed"} = Authentication.call(conn, User, PasswordRepo, %{"email" => "fake-exist@example.com", "password" => "bad-password"})
  end

  @tag fixtures: [:users]
  test "returns the `{:ok, conn, record}` if found by `email` and the `password` is correct", %{conn: conn, data: %{users: users}} do
    opts = Plug.Session.init(store: :cookie, key: "foobar", signing_salt: "foobar")
    conn = Plug.Session.call(conn, opts)

    {:ok, conn, user} = Authentication.call(conn, User, Repo, %{"email" => users.one.email, "password" => "password"})
    conn = Plug.Conn.fetch_session(conn)

    assert user == users.one
    assert_authorized_as(conn, user)
  end
end
