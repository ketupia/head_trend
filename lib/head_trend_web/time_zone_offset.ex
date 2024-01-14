defmodule HeadTrendWeb.TimeZoneOffset do
  @moduledoc """
  TimezoneOffset puts the timezone_offset from the socket connect params into the assigns on mount
  """
  def on_mount(:timezone_offset, _params, _session, socket) do
    timezone_offset = Phoenix.LiveView.get_connect_params(socket)["timezone_offset"] || 0

    {:cont, Phoenix.Component.assign(socket, :timezone_offset, timezone_offset)}
  end
end
