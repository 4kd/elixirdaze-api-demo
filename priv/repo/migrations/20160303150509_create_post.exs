defmodule ElixirDaze.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :body, :string
      add :published_at, :datetime
      add :user_id, references(:users)

      timestamps
    end

  end
end
