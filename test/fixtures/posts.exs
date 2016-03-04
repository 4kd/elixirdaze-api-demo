posts model: ElixirDaze.Post, repo: ElixirDaze.Repo do
  one do
    id 1
    title "Post One"
    body "This is a test post"
    user fixtures(:users).users.one
    published_at Ecto.DateTime.from_erl({{2016, 1, 1}, {0, 0, 0}})
  end

  two do
    id 2
    title "Post two"
    body "This is another test post"
    user fixtures(:users).users.two
    published_at Ecto.DateTime.from_erl({{2016, 1, 10}, {0, 0, 0}})
  end

  three do
    id 3
    title "Post Three"
    body "This is a test post"
    user fixtures(:users).users.one
    published_at Ecto.DateTime.from_erl({{2016, 3, 1}, {0, 0, 0}})
  end
end
