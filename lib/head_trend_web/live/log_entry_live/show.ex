defmodule HeadTrendWeb.LogEntryLive.Show do
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

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:log_entry, log_entry)}
  end

  defp page_title(:show), do: "Show Log entry"
  defp page_title(:edit), do: "Edit Log entry"

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    log_entry = Logs.get_log_entry!(id)
    {:ok, _} = Logs.delete_log_entry(log_entry)

    {:noreply, socket |> redirect(to: ~p"/log_entries")}
  end
end
