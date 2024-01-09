defmodule HeadTrend.Repo.Migrations.CreateLogEntries do
  use Ecto.Migration

  def change do
    create table(:log_entries) do
      add :occurred_on, :utc_datetime
      add :headache, :boolean, default: false, null: false
      add :fever, :boolean, default: false, null: false
      add :pain_reliever, :string
      add :debilitating, :boolean, default: false, null: false
      add :notes, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:log_entries, [:user_id])
  end
end
