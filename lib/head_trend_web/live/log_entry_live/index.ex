defmodule HeadTrendWeb.LogEntryLive.Index do
  alias HeadTrend.UserLogGenServer
  alias HeadTrend.UserLogPubSub
  use HeadTrendWeb, :live_view

  alias HeadTrend.Logs.LogEntry

  @impl true
  def mount(_params, _session, socket) do
    # UserLogGenServer.get_or_start(socket.assigns.current_user.id)

    if connected?(socket), do: UserLogPubSub.subscribe(socket.assigns.current_user.id)

    log_entries =
      UserLogGenServer.get_log_entries(socket.assigns.current_user.id)
      |> Enum.map(fn le ->
        Map.update!(le, :occurred_on, fn dt ->
          dt
          |> DateTime.shift_zone!(socket.assigns.timezone)
        end)
      end)

    {:ok, assign(socket, :log_entries, log_entries)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    new_log_entry =
      %LogEntry{
        pain_reliever: "- none -",
        occurred_on:
          DateTime.utc_now()
          |> DateTime.shift_zone!(socket.assigns.timezone)
      }

    socket
    |> assign(:page_title, "New Log entry")
    |> assign(:log_entry, new_log_entry)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Log entries")
    |> assign(:log_entry, nil)
  end

  # @impl true
  # def handle_event("delete", %{"id" => id}, socket) do
  #   log_entry = Logs.get_log_entry!(id)
  #   {:ok, _} = Logs.delete_log_entry(log_entry)

  #   {:noreply,
  #    assign(
  #      socket,
  #      :log_entries,
  #      Enum.reject(socket.assigns.log_entries, fn x -> x.id == log_entry.id end)
  #    )}
  # end

  @impl true
  def handle_info(%HeadTrend.UserLogPubSub.LogEntryCreated{log_entry: log_entry}, socket) do
    log_entry =
      Map.update!(log_entry, :occurred_on, fn dt ->
        dt
        |> DateTime.shift_zone!(socket.assigns.timezone)
      end)

    {:noreply, assign(socket, :log_entries, [log_entry | socket.assigns.log_entries])}
  end

  @impl true
  def handle_info(%HeadTrend.UserLogPubSub.LogEntryUpdated{log_entry: log_entry}, socket) do
    log_entries =
      case Enum.find_index(socket.assigns.log_entries, fn x ->
             x.id == log_entry.id
           end) do
        # not being displayed, so no need to update and show it!?!
        nil ->
          socket.assigns.log_entries

        index ->
          log_entry =
            Map.update!(log_entry, :occurred_on, fn dt ->
              dt
              |> DateTime.shift_zone!(socket.assigns.timezone)
            end)

          List.replace_at(socket.assigns.log_entries, index, log_entry)
      end

    {:noreply, assign(socket, :log_entries, log_entries)}
  end

  @impl true
  def handle_info(%HeadTrend.UserLogPubSub.LogEntryDeleted{log_entry: log_entry}, socket) do
    updated_log_entries =
      Enum.reject(socket.assigns.log_entries, fn le -> le.id == log_entry.id end)

    {:noreply, assign(socket, :log_entries, updated_log_entries)}
  end

  @impl true
  def handle_info(msg, socket) do
    IO.inspect(msg, label: "Unhandled msg")
    {:noreply, socket}
  end

  attr :log_entry, HeadTrend.Logs.LogEntry, required: true
  attr :current_user, HeadTrend.Accounts.User, required: true
  attr :page_title, :string, default: "Listing Log Entries"
  attr :live_action, :atom, default: :index

  def log_entry_form_modal(assigns) do
    ~H"""
    <.modal
      :if={@live_action in [:new]}
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
        timezone={@timezone}
        patch={~p"/log_entries"}
      />
    </.modal>
    """
  end
end
