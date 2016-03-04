defmodule ElixirDaze.Api.PostController do
  alias ElixirDaze.{Post, PostView, Repo}

  use ElixirDaze.Web, :controller
  use Inquisitor, with: Post

  def index(conn, params) do
    posts =
      build_post_query(params)
      |> preload([:user])
      |> Repo.all()

    render(conn, PostView, :index, data: posts)
  end

  def create(conn, %{"data" => %{"attributes" => attributes, "type" => "post"}}) do
    conn.assigns[:account]
    |> build_assoc(:posts)
    |> Post.changeset(attributes)
    |> Repo.insert()
    |> case do
      {:ok, post} ->
        post = Repo.preload(post, [:user])
        conn
        |> put_status(201)
        |> render(PostView, :show, data: post)
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(PostView, :errors, data: changeset)
    end
  end

  def update(conn, %{"id" => id, "data" => %{"attributes" => attributes, "type" => "post"}}) do
    conn
    |> find_post(id)
    |> case do
      nil -> send_resp(conn, 404, "")
      post ->
        post
        |> Post.changeset(attributes)
        |> Repo.update()
        |> case do
          {:ok, post} -> render(conn, PostView, :show, data: post)
          {:error, changeset} ->
            conn
            |> put_status(400)
            |> render(PostView, :errors, data: changeset)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    conn
    |> find_post(id)
    |> case do
      nil -> send_resp(conn, 404, "")
      post ->
        post
        |> Repo.delete()
        |> case do
          {:ok, _post} -> send_resp(conn, 204, "")
        end
    end
  end

  defp find_post(conn, id),
    do: conn.assigns[:account]
        |> assoc(:posts)
        |> preload([:user])
        |> Repo.get(id)

  defp build_post_query(query, [{attr, value} | tail]) when attr == "month" or attr == "year" do
    query
    |> Ecto.Query.where([p], fragment("date_part(?, ?) = ?", ^attr, p.published_at, type(^value, :integer)))
    |> build_post_query(tail)
  end

  defp build_post_query(query, [{"limit", limit} | tail]) do
    query
    |> Ecto.Query.limit(^limit)
    |> build_post_query(tail)
  end

  defp build_post_query(query, [{"order_by", field} | tail]) do
    query
    |> Ecto.Query.order_by([asc: ^field])
    |> build_post_query(tail)
  end
end
