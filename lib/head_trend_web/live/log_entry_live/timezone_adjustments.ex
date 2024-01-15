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
        0 -> "%a %b %_d, %_I:%M %p"
        _ -> "%a %b %_d, %Y %_I:%M %p"
      end

    Calendar.strftime(dt, format)
  end
end
