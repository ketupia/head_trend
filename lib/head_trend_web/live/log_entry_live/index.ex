defmodule HeadTrendWeb.LogEntryLive.Index do
  use HeadTrendWeb, :live_view

  alias HeadTrend.Logs
  alias HeadTrend.Logs.LogEntry

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :log_entries, Logs.list_log_entries(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Log entry")
    |> assign(:log_entry, Logs.get_log_entry!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Log entry")
    |> assign(:log_entry, %LogEntry{
      # occurred_on: DateTime.utc_now(),
      pain_reliever: "- none -"
    })
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Log entries")
    |> assign(:log_entry, nil)
  end

  @impl true
  def handle_info({HeadTrendWeb.LogEntryLive.FormComponent, {:saved, log_entry}}, socket) do
    {:noreply, stream_insert(socket, :log_entries, log_entry, at: 0)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    log_entry = Logs.get_log_entry!(id)
    {:ok, _} = Logs.delete_log_entry(log_entry)

    {:noreply, stream_delete(socket, :log_entries, log_entry)}
  end
end
