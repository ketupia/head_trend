defmodule HeadTrendWeb.LogEntryLive.Show do
  alias HeadTrend.Logs.LogEntry
  alias HeadTrendWeb.LogEntryLive.TimezoneAdjustments
  use HeadTrendWeb, :live_view

  alias HeadTrend.Logs

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    log_entry =
      Logs.get_log_entry!(id)
      |> Map.update!(:occurred_on, fn dt ->
        DateTime.shift_zone!(dt, socket.assigns.timezone)
      end)
      |> maybe_format_for_display(socket.assigns.live_action)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:log_entry, log_entry)}
  end

  defp maybe_format_for_display(%LogEntry{} = log_entry, :show) do
    Map.update!(log_entry, :occurred_on, fn dt ->
      TimezoneAdjustments.format_for_display(dt)
    end)
  end

  defp maybe_format_for_display(%LogEntry{} = log_entry, _live_action), do: log_entry

  defp page_title(:show), do: "Show Log entry"
  defp page_title(:edit), do: "Edit Log entry"
end
