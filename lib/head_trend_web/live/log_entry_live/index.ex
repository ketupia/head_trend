defmodule HeadTrendWeb.LogEntryLive.Index do
  alias HeadTrendWeb.LogEntryLive.FormComponent.NotifyParentEvents.LogEntryCreated
  alias HeadTrendWeb.LogEntryLive.FormComponent.NotifyParentEvents.LogEntryUpdated
  alias HeadTrendWeb.LogEntryLive.FormComponent
  use HeadTrendWeb, :live_view

  alias HeadTrend.Logs
  alias HeadTrend.Logs.LogEntry

  @impl true
  def mount(_params, _session, socket) do
    # IO.inspect(Map.get(socket.assigns, :timezone_offset), label: "MOUNT Timezone Offset")

    log_entries =
      Logs.list_log_entries(socket.assigns.current_user.id)
      |> Enum.map(fn le ->
        HeadTrendWeb.LogEntryLive.TimezoneAdjustments.utc_to_local(le, :occurred_on, socket)
      end)

    {:ok, assign(socket, :log_entries, log_entries)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    log_entry =
      Logs.get_log_entry!(id)
      |> HeadTrendWeb.LogEntryLive.TimezoneAdjustments.utc_to_local(:occurred_on, socket)

    socket
    |> assign(:page_title, "Edit Log entry")
    |> assign(:log_entry, log_entry)
  end

  defp apply_action(socket, :new, _params) do
    new_log_entry =
      %LogEntry{
        pain_reliever: "- none -",
        occurred_on: DateTime.utc_now()
      }
      |> HeadTrendWeb.LogEntryLive.TimezoneAdjustments.utc_to_local(:occurred_on, socket)

    socket
    |> assign(:page_title, "New Log entry")
    |> assign(:log_entry, new_log_entry)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Log entries")
    |> assign(:log_entry, nil)
  end

  @impl true
  def handle_info(
        {FormComponent, %LogEntryCreated{log_entry: log_entry}},
        socket
      ) do
    log_entry =
      HeadTrendWeb.LogEntryLive.TimezoneAdjustments.utc_to_local(log_entry, :occurred_on, socket)

    {:noreply, assign(socket, :log_entries, [log_entry | socket.assigns.log_entries])}
  end

  @impl true
  def handle_info(
        {FormComponent, %LogEntryUpdated{log_entry: log_entry}},
        socket
      ) do
    log_entry =
      HeadTrendWeb.LogEntryLive.TimezoneAdjustments.utc_to_local(log_entry, :occurred_on, socket)

    log_entries =
      case Enum.find_index(socket.assigns.log_entries, fn x ->
             x.id == log_entry.id
           end) do
        # not being displayed, so no need to update
        nil -> socket.assigns.log_entries
        index -> List.replace_at(socket.assigns.log_entries, index, log_entry)
      end

    {:noreply, assign(socket, :log_entries, log_entries)}
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
