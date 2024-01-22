defmodule HeadTrendWeb.LogEntryLive.FormComponent do
  alias HeadTrendWeb.LogEntryLive.TimezoneAdjustments
  use HeadTrendWeb, :live_component

  alias HeadTrend.Logs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage log_entry records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="log_entry-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:occurred_on]} type="datetime-local" label="Occurred on" />
        <.input field={@form[:headache]} type="checkbox" label="Headache" />
        <.input field={@form[:fever]} type="checkbox" label="Fever" />
        <.input
          field={@form[:pain_reliever]}
          type="select"
          label="Pain reliever"
          options={["- none -": "- none -", acetaminophen: "acetaminophen", ibuprofen: "ibuprofen"]}
        />
        <.input field={@form[:debilitating]} type="checkbox" label="Debilitating" />
        <.input field={@form[:notes]} type="textarea" label="Notes" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Log entry</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{log_entry: log_entry} = assigns, socket) do
    changeset = Logs.change_log_entry(log_entry)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"log_entry" => log_entry_params}, socket) do
    changeset =
      socket.assigns.log_entry
      |> Logs.change_log_entry(log_entry_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"log_entry" => log_entry_params}, socket) do
    save_log_entry(socket, socket.assigns.action, log_entry_params)
  end

  use TypedStruct

  typedstruct module: LogEntryCreated, enforce: true do
    field :log_entry, HeadTrend.Logs.LogEntry.t()
  end

  typedstruct module: LogEntryUpdated, enforce: true do
    field :log_entry, HeadTrend.Logs.LogEntry.t()
  end

  defp save_log_entry(socket, :edit, log_entry_params) do
    log_entry_params =
      Map.update!(log_entry_params, "occurred_on", fn x ->
        TimezoneAdjustments.parse_from_input(x, socket.assigns.timezone)
      end)

    case Logs.update_log_entry(socket.assigns.log_entry, log_entry_params) do
      {:ok, log_entry} ->
        notify_parent(%HeadTrendWeb.LogEntryLive.FormComponent.LogEntryUpdated{
          log_entry: log_entry
        })

        {:noreply,
         socket
         #  |> put_flash(:info, "Log entry updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_log_entry(socket, :new, log_entry_params) do
    case log_entry_params
         |> Map.update!("occurred_on", fn x ->
           TimezoneAdjustments.parse_from_input(x, socket.assigns.timezone)
         end)
         |> Map.put("user_id", socket.assigns.current_user.id)
         |> Logs.create_log_entry() do
      {:ok, log_entry} ->
        notify_parent(%HeadTrendWeb.LogEntryLive.FormComponent.LogEntryCreated{
          log_entry: log_entry
        })

        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
