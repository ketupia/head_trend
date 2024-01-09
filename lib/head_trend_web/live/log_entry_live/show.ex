defmodule HeadTrendWeb.LogEntryLive.Show do
  use HeadTrendWeb, :live_view

  alias HeadTrend.Logs

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:log_entry, Logs.get_log_entry!(id))}
  end

  defp page_title(:show), do: "Show Log entry"
  defp page_title(:edit), do: "Edit Log entry"
end
