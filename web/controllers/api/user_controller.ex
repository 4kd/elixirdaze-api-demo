defmodule Elixirdaze.Api.UserController do
  use Elixirdaze.Web, :controller

  alias Elixirdaze.{Repo, User, UserView}

  def create(conn, %{"data" => %{"attributes" => attributes, "type" => "user"}}) do
    %User{}
    |> User.changeset(attributes)
    |> Repo.insert()
    |> case do
      {:ok, user} ->
        conn
        |> put_status(201)
        |> render(UserView, :show, data: user)
      {:error, _changeset} -> send_resp(conn, 422, "")
    end
  end
end
