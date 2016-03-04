posts model: Elixirdaze.Post, repo: Elixirdaze.Repo do
  one do
    title "Post One"
    body "This is a test post"
    user fixtures(:users).users.one
    published_at Ecto.DateTime.from_erl({{2016, 1, 1}, {0, 0, 0}})
  end

  two do
    title "Post two"
    body "This is another test post"
    user fixtures(:users).users.two
    published_at Ecto.DateTime.from_erl({{2016, 1, 10}, {0, 0, 0}})
  end

  three do
    title "Post Three"
    body "This is a test post"
    user fixtures(:users).users.one
    published_at Ecto.DateTime.from_erl({{2016, 3, 1}, {0, 0, 0}})
  end
end
