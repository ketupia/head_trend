defmodule HeadTrendWeb.TimezoneOnMount do
  @moduledoc """
  TimezoneOnMount puts the timezone from the socket connect params into the assigns
  """
  def on_mount(:timezone, _params, _session, socket) do
    timezone = Phoenix.LiveView.get_connect_params(socket)["timezone"] || "UTC"

    {:cont,
     socket
     |> Phoenix.Component.assign(:timezone, timezone)}
  end
end
