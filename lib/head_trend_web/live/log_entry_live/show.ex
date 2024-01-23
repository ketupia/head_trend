defmodule HeadTrendWeb.LogEntryLive.Show do
  alias HeadTrend.UserLogGenServer
  use HeadTrendWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: HeadTrend.UserLogPubSub.subscribe(socket.assigns.current_user.id)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    log_entry =
      UserLogGenServer.get_log_entry(socket.assigns.current_user.id, id)
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
    UserLogGenServer.get_log_entry(socket.assigns.current_user.id, id)
    |> UserLogGenServer.delete_log_entry()

    {:noreply, socket |> redirect(to: ~p"/log_entries")}
  end

  @impl true
  def handle_info(%HeadTrend.UserLogPubSub.LogEntryUpdated{log_entry: log_entry}, socket)
      when log_entry.id == socket.assigns.log_entry.id do
    log_entry =
      log_entry
      |> Map.update!(:occurred_on, fn dt ->
        DateTime.shift_zone!(dt, socket.assigns.timezone)
      end)

    {:noreply, socket |> assign(:log_entry, log_entry)}
  end
end
