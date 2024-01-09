defmodule HeadTrend.Repo do
  use Ecto.Repo,
    otp_app: :head_trend,
    adapter: Ecto.Adapters.Postgres
end
