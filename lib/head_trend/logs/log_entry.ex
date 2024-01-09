defmodule HeadTrend.Logs.LogEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "log_entries" do
    field :occurred_on, :utc_datetime
    field :headache, :boolean, default: false
    field :fever, :boolean, default: false
    field :pain_reliever, :string
    field :debilitating, :boolean, default: false
    field :notes, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(log_entry, attrs) do
    log_entry
    |> cast(attrs, [
      :occurred_on,
      :headache,
      :fever,
      :pain_reliever,
      :debilitating,
      :notes,
      :user_id
    ])
    |> validate_required([
      :occurred_on,
      :headache,
      :fever,
      :pain_reliever,
      :debilitating,
      :user_id
    ])
  end
end
