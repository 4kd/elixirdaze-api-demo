defmodule ElixirDaze.PostView do
  use ElixirDaze.Web, :view
  use JaSerializer.PhoenixView

  attributes [:title, :body]
  has_one :user, serializer: ElixirDaze.UserView, include: false
end
