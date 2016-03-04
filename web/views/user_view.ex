defmodule ElixirDaze.UserView do
  use ElixirDaze.Web, :view
  use JaSerializer.PhoenixView

  attributes [:email, :name]
end
