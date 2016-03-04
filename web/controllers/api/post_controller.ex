defmodule ElixirDaze.Api.PostController do
  alias ElixirDaze.{Post, PostView, Repo}

  use ElixirDaze.Web, :controller

  def index(conn, params) do
    posts =
      build_query(params)
      |> preload([:user])
      |> Repo.all()

    render(conn, PostView, :index, data: posts)
  end

  def build_query(params) when is_map(params) do
    build_query(Post, Map.to_list(params))
  end

  def build_query(q, []), do: q
  def build_query(q, [{key, value} | tail]) do
    Ecto.Query.where(q, [r], field(r, ^String.to_existing_atom(key)) == ^value)
    |> build_query(tail)
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

end
