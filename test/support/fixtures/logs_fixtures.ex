defmodule HeadTrend.LogsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HeadTrend.Logs` context.
  """

  @doc """
  Generate a log_entry.
  """
  def log_entry_fixture(attrs \\ %{}) do
    {:ok, log_entry} =
      attrs
      |> Enum.into(%{
        fever: true,
        headache: true,
        occurred_on: ~U[2023-12-30 16:58:00Z],
        pain_reliever: "some pain_reliever"
      })
      |> HeadTrend.Logs.create_log_entry()

    log_entry
  end
end
