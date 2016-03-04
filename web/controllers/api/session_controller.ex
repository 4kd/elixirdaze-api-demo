defmodule Elixirdaze.Api.SessionController do
  use Elixirdaze.Web, :controller

  alias Elixirdaze.{Repo, User, UserView, Strategies.Authentication}

  def create(conn, credentials) do
    Authentication.call(conn, User, Repo, credentials)
    |> case do
      {:ok, conn, account} ->
        conn
        |> put_status(200)
        |> render(UserView, :show, data: account)
      {:unauthorized, _message} -> send_resp(conn, 401, "")
    end
  end

  def delete(conn, _params) do
    conn
    |> Plug.Conn.delete_session(:account_id)
    |> Plug.Conn.delete_session(:account_type)
    |> Map.put(:assigns, Map.delete(conn.assigns, :account))
    |> send_resp(204, "")
  end
end
