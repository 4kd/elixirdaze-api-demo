defmodule ElixirDaze.Strategies.Authorization do
  import Plug.Conn
  import Ecto.Query

  def init([admin: admin?]),
    do: !!admin?
  def init([]), do: false

  def call(conn, admin? \\ false)
  def call(%Plug.Conn{assigns: %{account: _account}} = conn, false),
    do: conn
  def call(%Plug.Conn{assigns: %{account: %{admin: true}}} = conn, true),
    do: conn
  def call(%Plug.Conn{assigns: %{account: _account}} = conn, true),
    do: unauthorize(conn)
  def call(conn, admin?) do
    conn
    |> account_id_check()
    |> account_type_check()
    |> account_authorize(admin?)
  end

  defp account_id_check(%Plug.Conn{halted: true} = conn),
    do: conn
  defp account_id_check(%Plug.Conn{} = conn) do
    case get_session(conn, :account_id) do
      nil -> unauthorize(conn)
      _account_id -> conn
    end
  end

  defp account_type_check(%Plug.Conn{halted: true} = conn),
    do: conn
  defp account_type_check(%Plug.Conn{} = conn) do
    case get_session(conn, :account_type) do
      nil -> unauthorize(conn)
      _account_type -> conn
    end
  end

  defp account_authorize(%Plug.Conn{halted: true} = conn, _admin?),
    do: conn
  defp account_authorize(%Plug.Conn{} = conn, admin?) do
    query = account_find(conn)

    case ElixirDaze.Repo.one(query) do
      nil -> unauthorize(conn)
      account -> admin_check(conn, account, admin?)
    end
  end

  defp account_find(conn) do
    account_id = get_session(conn, :account_id)
    account_type = get_session(conn, :account_type)

    [primary_key] = account_type.__schema__(:primary_key)
    account_type
    |> where([a], field(a, ^primary_key) == ^account_id)
  end

  defp admin_check(conn, account, false),
    do: assign(conn, :account, account)
  defp admin_check(conn, %{admin: true} = account, true),
    do: admin_check(conn, account, false)
  defp admin_check(conn, _account, true),
    do: unauthorize(conn)

  defp unauthorize(conn) do
    conn
    |> send_resp(401, "")
    |> halt()
  end
end
