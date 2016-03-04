defmodule Elixirdaze.Api.PostsTest do
  use Elixirdaze.ConnCase
  use AuthTestSupport
  use EctoFixtures
  import Voorhees.JSONApi
  import Elixirdaze.JsonFor

  alias Elixirdaze.{Post, Repo}

  require_authorization :post_path, only: [:create, :update, :delete]

  @tag fixtures: [:users]
  test "creating a new post as a user", %{conn: conn, data: %{users: users}} do
    count =
      users.one
      |> Ecto.assoc(:posts)
      |> Repo.all()
      |> length()

    conn =
      conn
      |> authorize_as(users.one)
      |> post(post_path(conn, :create), json_for(:post, %{title: "Test title", body: String.duplicate("a", 100)}))
      |> json_response(201)

    posts =
      users.one
      |> Ecto.assoc(:posts)
      |> Repo.all()

    post = List.last(posts)

    conn
    |> assert_data(post)
    |> assert_relationship(users.one, for: post)

    assert count + 1 == length(posts)
  end

  @tag fixtures: [:users]
  test "creating a new post as a user with bad data", %{conn: conn, data: %{users: users}} do
    count =
      users.one
      |> Ecto.assoc(:posts)
      |> Repo.all()
      |> length()

    conn
    |> authorize_as(users.one)
    |> post(post_path(conn, :create), json_for(:post, %{title: "Test title", body: "too short"}))
    |> json_response(400)

    posts =
      users.one
      |> Ecto.assoc(:posts)
      |> Repo.all()

    assert count == length(posts)
  end

  @tag fixtures: [:posts]
  test "updating post as a user", %{conn: conn, data: %{users: users, posts: posts}} do
    conn =
      conn
      |> authorize_as(users.one)
      |> put(post_path(conn, :update, posts.one.id), json_for(:post, %{title: "New title"}))
      |> json_response(200)

    post = Repo.get(Post, posts.one.id)

    assert post.title == "New title"

    conn
    |> assert_data(post)
    |> assert_relationship(users.one, for: post)
  end

  @tag fixtures: [:posts]
  test "updating post as a user with invalid data", %{conn: conn, data: %{users: users, posts: posts}} do
    conn
    |> authorize_as(users.one)
    |> put(post_path(conn, :update, posts.one.id), json_for(:post, %{body: "too short"}))
    |> json_response(400)
  end

  @tag fixtures: [:posts]
  test "updating post as a user you don't own", %{conn: conn, data: %{users: users, posts: posts}} do
    conn =
      conn
      |> authorize_as(users.one)
      |> put(post_path(conn, :update, posts.two.id), json_for(:post, %{title: "New title"}))

    post = Repo.get(Post, posts.one.id)
    refute post.title == "New title"
    assert conn.status == 404
  end

  @tag fixtures: [:posts]
  test "deleting a post as a user", %{conn: conn, data: %{users: users, posts: posts}} do
    count = Repo.all(Post) |> length()

    conn =
      conn
      |> authorize_as(users.one)
      |> delete(post_path(conn, :delete, posts.one.id))

    assert conn.status == 204
    assert count - 1 == Repo.all(Post) |> length()
  end

  @tag fixtures: [:posts]
  test "deleting a post as a user you don't own", %{conn: conn, data: %{users: users, posts: posts}} do
    count = Repo.all(Post) |> length()

    conn =
      conn
      |> authorize_as(users.one)
      |> delete(post_path(conn, :delete, posts.two.id))

    assert conn.status == 404
    assert count == Repo.all(Post) |> length()
  end

  @tag fixtures: [:users]
  test "deleting a post that doesn't exist", %{conn: conn, data: %{users: users}} do
    conn =
      conn
      |> authorize_as(users.one)
      |> delete(post_path(conn, :delete, 1))

    assert conn.status == 404
  end

  @tag fixtures: [:posts]
  test "index querying for all posts", %{conn: conn, data: %{users: users, posts: posts}} do
    conn
    |> get(post_path(conn, :index))
    |> json_response(200)
    |> assert_data(posts.one)
    |> assert_relationship(users.one, for: posts.one)
    |> assert_data(posts.two)
    |> assert_relationship(users.two, for: posts.two)
    |> assert_data(posts.three)
    |> assert_relationship(users.one, for: posts.three)
  end

  @tag fixtures: [:posts]
  test "index querying by user_id", %{conn: conn, data: %{users: users, posts: posts}} do
    conn
    |> get(post_path(conn, :index), %{user_id: users.one.id})
    |> json_response(200)
    |> assert_data(posts.one)
    |> assert_relationship(users.one, for: posts.one)
    |> refute_data(posts.two)
    |> assert_data(posts.three)
    |> assert_relationship(users.one, for: posts.three)
  end

  @tag fixtures: [:posts]
  test "index querying by month and year", %{conn: conn, data: %{users: users, posts: posts}} do
    conn
    |> get(post_path(conn, :index), %{month: 1, year: 2016})
    |> json_response(200)
    |> assert_data(posts.one)
    |> assert_relationship(users.one, for: posts.one)
    |> assert_data(posts.two)
    |> assert_relationship(users.two, for: posts.two)
    |> refute_data(posts.three)
  end

  @tag fixtures: [:posts]
  test "index querying can limit", %{conn: conn, data: %{users: users, posts: posts}} do
    data = conn
      |> get(post_path(conn, :index), %{limit: 1, month: 1, year: 2016, order_by: :published_at})
      |> json_response(200)
      |> assert_data(posts.one)
      |> assert_relationship(users.one, for: posts.one)

    assert length(data["data"]) == 1
  end
end
