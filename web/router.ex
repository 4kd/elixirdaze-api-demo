defmodule Elixirdaze.Router do
  use Elixirdaze.Web, :router

  pipeline :api do
    plug :accepts, ["json-api"]
    plug :fetch_session
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  pipeline :authorized do
    plug Elixirdaze.Strategies.Authorization
  end

  scope "/api", Elixirdaze.Api do
    pipe_through :api

    resources "/users", UserController
    resources "/posts", PostController, only: [:index, :show]
    resources "/sessions", SessionController, only: [:create, :delete], singleton: true

    scope "/" do
      pipe_through :authorized

      resources "/posts", PostController, only: [:create, :update, :delete]
    end
  end
end
