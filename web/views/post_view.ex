defmodule ElixirDaze.PostView do
  use ElixirDaze.Web, :view
  use JaSerializer.PhoenixView

  attributes [:title, :body, :published_at]
  has_one :user, serializer: ElixirDaze.UserView, include: false
end
