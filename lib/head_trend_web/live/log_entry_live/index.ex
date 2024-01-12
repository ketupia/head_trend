defmodule HeadTrendWeb.LogEntryLive.Index do
  use HeadTrendWeb, :live_view

  alias HeadTrend.Logs
  alias HeadTrend.Logs.LogEntry

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :log_entries, Logs.list_log_entries(socket.assigns.current_user.id))}
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
    {:noreply, assign(socket, :log_entries, [log_entry | socket.assigns.log_entries])}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    log_entry = Logs.get_log_entry!(id)
    {:ok, _} = Logs.delete_log_entry(log_entry)

    {:noreply,
     assign(
       socket,
       :log_entries,
       Enum.reject(socket.assigns.log_entries, fn x -> x.id == log_entry.id end)
     )}
  end

  def new_log_entry_button(assigns) do
    ~H"""
    <.link patch={~p"/log_entries/new"}>
      <.button>New Log entry</.button>
    </.link>
    """
  end

  attr :log_entry, HeadTrend.Logs.LogEntry, required: true
  attr :current_user, HeadTrend.Accounts.User, required: true
  attr :page_title, :string, default: "Listing Log Entries"
  attr :live_action, :atom, default: :index

  def log_entry_form_modal(assigns) do
    ~H"""
    <.modal
      :if={@live_action in [:new, :edit]}
      id="log_entry-modal"
      show
      on_cancel={JS.patch(~p"/log_entries")}
    >
      <.live_component
        module={HeadTrendWeb.LogEntryLive.FormComponent}
        id={@log_entry.id || :new}
        title={@page_title}
        action={@live_action}
        log_entry={@log_entry}
        current_user={@current_user}
        patch={~p"/log_entries"}
      />
    </.modal>
    """
  end
end
