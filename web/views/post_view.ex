defmodule Elixirdaze.PostView do
  use Elixirdaze.Web, :view
  use JaSerializer.PhoenixView

  attributes [:title, :body]
  has_one :user, serializer: Elixirdaze.UserView, include: false
end
