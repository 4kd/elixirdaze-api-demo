defmodule ElixirDaze.Api.PostsTest do
  use ElixirDaze.ConnCase
  use AuthTestSupport
  use EctoFixtures

  alias ElixirDaze.{Post, Repo}

  require_authorization :post_path, only: [:create, :update, :delete]

  @tag fixtures: [:users]
  test "creating a new post as a user", %{conn: conn, data: %{users: users}} do
    count =
      users.one
      |> Ecto.assoc(:posts)
      |> Repo.all()
      |> length()

    data = %{
      "data" => %{
        "type" => "post",
        "attributes" => %{
          "title" => "Test title",
          "body" => String.duplicate("a", 100)
        },
        "format" => "json-api"
      }
    }

    payload =
      conn
      |> post(session_path(conn, :create), %{email: users.one.email, password: "password"})
      |> recycle()
      |> Plug.Conn.put_req_header("content-type", "application/vnd.api+json")
      |> post(post_path(conn, :create), data)
      |> json_response(201)

    posts =
      users.one
      |> Ecto.assoc(:posts)
      |> Repo.all()

    post = List.last(posts)

    expected_payload = %{
      "data" => %{
        "attributes" => %{
          "title" => "Test title",
          "body" => String.duplicate("a", 100),
          "published-at" => nil,
        },
        "relationships" => %{
          "user" => %{
            "data" => %{
              "type" => "user",
              "id" => "#{users.one.id}"
            }
          }
        },
        "id" => "#{post.id}",
        "type" => "post"
      },
      "jsonapi" => %{"version" => "1.0"}
    }

    assert payload == expected_payload

    assert count + 1 == length(posts)
  end

  @tag fixtures: [:users]
  test "creating a new post as a user with bad data", %{conn: conn, data: %{users: users}} do
    count =
      users.one
      |> Ecto.assoc(:posts)
      |> Repo.all()
      |> length()

    data = %{
      "data" => %{
        "type" => "post",
        "attributes" => %{
          "title" => "Test title",
          "body" => "too short"
        },
        "format" => "json-api"
      }
    }

    conn
    |> post(session_path(conn, :create), %{email: users.one.email, password: "password"})
    |> recycle()
    |> Plug.Conn.put_req_header("content-type", "application/vnd.api+json")
    |> post(post_path(conn, :create), data)
    |> json_response(400)

    posts =
      users.one
      |> Ecto.assoc(:posts)
      |> Repo.all()

    assert count == length(posts)
  end

  @tag fixtures: [:posts]
  test "updating post as a user", %{conn: conn, data: %{users: users, posts: posts}} do
    data = %{
      "data" => %{
        "id" => "#{posts.one.id}",
        "type" => "post",
        "attributes" => %{
          "title" => "New title",
          "body" => String.duplicate("a", 100)
        },
        "format" => "json-api"
      }
    }

    payload =
      conn
      |> authorize_as(users.one)
      |> put(post_path(conn, :update, posts.one.id), data)
      |> json_response(200)

    post = Repo.get(Post, posts.one.id)

    assert post.title == "New title"

    expected_payload = %{
      "data" => %{
        "attributes" => %{
          "title" => "New title",
          "body" => String.duplicate("a", 100),
          "published-at" => "2016-01-01T00:00:00Z",
        },
        "relationships" => %{
          "user" => %{
            "data" => %{
              "type" => "user",
              "id" => "#{users.one.id}"
            }
          }
        },
        "id" => "#{post.id}",
        "type" => "post"
      },
      "jsonapi" => %{"version" => "1.0"}
    }

    assert payload == expected_payload
  end

  @tag fixtures: [:posts]
  test "updating post as a user with invalid data", %{conn: conn, data: %{users: users, posts: posts}} do
    data = %{
      "data" => %{
        "type" => "post",
        "id" => "#{posts.one.id}",
        "attributes" => %{
          "title" => "Test title",
          "body" => "too short"
        },
        "format" => "json-api"
      }
    }

    conn
    |> post(session_path(conn, :create), %{email: users.one.email, password: "password"})
    |> recycle()
    |> Plug.Conn.put_req_header("content-type", "application/vnd.api+json")
    |> put(post_path(conn, :update, posts.one.id), data)
    |> json_response(400)
  end

  @tag fixtures: [:posts]
  test "updating post as a user you don't own", %{conn: conn, data: %{users: users, posts: posts}} do
    data = %{
      "data" => %{
        "id" => "#{posts.one.id}",
        "type" => "post",
        "attributes" => %{
          "title" => "New title",
          "body" => String.duplicate("a", 100)
        },
        "format" => "json-api"
      }
    }

    conn =
      conn
      |> post(session_path(conn, :create), %{email: users.one.email, password: "password"})
      |> recycle()
      |> Plug.Conn.put_req_header("content-type", "application/vnd.api+json")
      |> put(post_path(conn, :update, posts.two.id), data)

    post = Repo.get(Post, posts.one.id)
    refute post.title == "New title"
    assert conn.status == 404
  end

  @tag fixtures: [:posts]
  test "deleting a post as a user", %{conn: conn, data: %{users: users, posts: posts}} do
    count = Repo.all(Post) |> length()

    conn =
      conn
      |> post(session_path(conn, :create), %{email: users.one.email, password: "password"})
      |> recycle()
      |> Plug.Conn.put_req_header("content-type", "application/vnd.api+json")
      |> delete(post_path(conn, :delete, posts.one.id))

    assert conn.status == 204
    assert count - 1 == Repo.all(Post) |> length()
  end

  @tag fixtures: [:posts]
  test "deleting a post as a user you don't own", %{conn: conn, data: %{users: users, posts: posts}} do
    count = Repo.all(Post) |> length()

    conn =
      conn
      |> post(session_path(conn, :create), %{email: users.one.email, password: "password"})
      |> recycle()
      |> Plug.Conn.put_req_header("content-type", "application/vnd.api+json")
      |> delete(post_path(conn, :delete, posts.two.id))

    assert conn.status == 404
    assert count == Repo.all(Post) |> length()
  end

  @tag fixtures: [:users]
  test "deleting a post that doesn't exist", %{conn: conn, data: %{users: users}} do
    conn =
      conn
      |> post(session_path(conn, :create), %{email: users.one.email, password: "password"})
      |> recycle()
      |> Plug.Conn.put_req_header("content-type", "application/vnd.api+json")
      |> delete(post_path(conn, :delete, 1))

    assert conn.status == 404
  end

  @tag fixtures: [:posts]
  test "index querying for all posts", %{conn: conn, data: %{users: users, posts: posts}} do
    expected_payload = %{
      "data" => [%{
        "attributes" => %{
          "title" => posts.one.title,
          "body" => posts.one.body,
          "published-at" => Ecto.DateTime.to_iso8601(posts.one.published_at),
        },
        "relationships" => %{
          "user" => %{
            "data" => %{
              "type" => "user",
              "id" => "#{users.one.id}"
            }
          }
        },
        "id" => "#{posts.one.id}",
        "type" => "post"
      }, %{
        "attributes" => %{
          "title" => posts.two.title,
          "body" => posts.two.body,
          "published-at" => Ecto.DateTime.to_iso8601(posts.two.published_at),
        },
        "relationships" => %{
          "user" => %{
            "data" => %{
              "type" => "user",
              "id" => "#{users.two.id}"
            }
          }
        },
        "id" => "#{posts.two.id}",
        "type" => "post"
      }, %{
        "attributes" => %{
          "title" => posts.three.title,
          "body" => posts.three.body,
          "published-at" => Ecto.DateTime.to_iso8601(posts.three.published_at),
        },
        "relationships" => %{
          "user" => %{
            "data" => %{
              "type" => "user",
              "id" => "#{users.one.id}"
            }
          }
        },
        "id" => "#{posts.three.id}",
        "type" => "post"
      }],
      "jsonapi" => %{"version" => "1.0"}
    }

    payload =
      conn
      |> get(post_path(conn, :index))
      |> json_response(200)

    assert payload == expected_payload
  end

  @tag fixtures: [:posts]
  test "index querying by user_id", %{conn: conn, data: %{users: users, posts: posts}} do
    expected_payload = %{
      "data" => [%{
        "attributes" => %{
          "title" => posts.one.title,
          "body" => posts.one.body,
          "published-at" => Ecto.DateTime.to_iso8601(posts.one.published_at),
        },
        "relationships" => %{
          "user" => %{
            "data" => %{
              "type" => "user",
              "id" => "#{users.one.id}"
            }
          }
        },
        "id" => "#{posts.one.id}",
        "type" => "post"
      }, %{
        "attributes" => %{
          "title" => posts.three.title,
          "body" => posts.three.body,
          "published-at" => Ecto.DateTime.to_iso8601(posts.three.published_at),
        },
        "relationships" => %{
          "user" => %{
            "data" => %{
              "type" => "user",
              "id" => "#{users.one.id}"
            }
          }
        },
        "id" => "#{posts.three.id}",
        "type" => "post"
      }],
      "jsonapi" => %{"version" => "1.0"}
    }
    payload =
      conn
      |> get(post_path(conn, :index), %{user_id: users.one.id})
      |> json_response(200)

    assert payload == expected_payload
  end
end
