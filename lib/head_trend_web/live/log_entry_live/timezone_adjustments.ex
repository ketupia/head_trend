defmodule HeadTrendWeb.LogEntryLive.TimezoneAdjustments do
  @spec parse_from_input(String.t(), Calendar.time_zone()) :: DateTime.t()
  def parse_from_input(input, timezone) do
    input
    |> String.pad_trailing(19, ":00")
    |> NaiveDateTime.from_iso8601!()
    |> DateTime.from_naive!(timezone)
  end

  @doc """
  See https://hexdocs.pm/elixir/Calendar.html#strftime/3 from strftime codes
  """
  def format_for_display(%DateTime{} = dt) do
    diff = DateTime.diff(DateTime.utc_now(), dt, :second)
    years = div(diff, 60 * 60 * 24 * 365)

    format =
      case years do
        0 -> "%a %b %_d, %_I:%M %P"
        _ -> "%a %b %_d, %Y %_I:%M %P"
      end

    Calendar.strftime(dt, format)
  end

  def format_for_display(%Date{} = d) do
    diff = Date.diff(Date.utc_today(), d)
    years = div(diff, 365)

    format =
      case years do
        0 -> "%a %b %_d"
        _ -> "%a %b %_d, %Y"
      end

    Calendar.strftime(d, format)
  end

  def format_for_display(%Time{} = t) do
    Calendar.strftime(t, "%_I:%M %P")
  end
end
