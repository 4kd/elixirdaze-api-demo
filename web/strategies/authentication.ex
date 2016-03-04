defmodule ElixirDaze.Strategies.Authentication do
  import Ecto.Query
  import Comeonin.Bcrypt
  import Plug.Conn, only: [put_session: 3, fetch_session: 1]

  alias ElixirDaze.{User}

  def call(conn, module, repo, %{"email" => email, "password" => password}) do
    module
    |> where(email: ^email)
    |> repo.one()
    |> case do
      nil -> {:unauthorized, "record not found"}
      account ->
        cond do
          checkpw(password, account.password_hash) ->
            conn =
              conn
              |> fetch_session()
              |> put_session(:account_id, account.id)
              |> put_session(:account_type, account.__struct__)
            {:ok, conn, account}
          true -> {:unauthorized, "token check failed"}
        end
    end
  end
end
