defmodule Elixirdaze.UserView do
  use Elixirdaze.Web, :view
  use JaSerializer.PhoenixView

  attributes [:email, :name]
end
