users model: Elixirdaze.User, repo: Elixirdaze.Repo do
  one do
    name "Brian"
    email "one@example.com"
    password_hash Comeonin.Bcrypt.hashpwsalt("password")
  end

  two do
    name "Stephanie"
    email "two@example.com"
    password_hash Comeonin.Bcrypt.hashpwsalt("password")
  end
end
