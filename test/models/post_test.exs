defmodule ElixirDaze.PostTest do
  use ElixirDaze.ModelCase
  import ValidField

  alias ElixirDaze.Post

  test "validations" do
    %Post{}
    |> with_changeset()
    |> assert_field(:title, ["Some title"], [nil, ""])
    |> assert_field(:body, [String.duplicate("a", 100)], [nil, "", String.duplicate("a", 99)])
  end
end
