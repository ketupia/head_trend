defmodule HeadTrendWeb.LogEntryLive.TimezoneAdjustments do
  @spec parse_from_input(String.t(), Calendar.time_zone()) :: DateTime.t()
  def parse_from_input(input, timezone) do
    input
    |> String.pad_trailing(19, ":00")
    |> NaiveDateTime.from_iso8601!()
    |> DateTime.from_naive!(timezone)
  end

  def format_for_display(%DateTime{} = dt) do
    Calendar.strftime(dt, "%a %b %d, %y %I:%M %p")
  end
end
