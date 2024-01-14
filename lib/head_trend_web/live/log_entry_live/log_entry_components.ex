defmodule HeadTrendWeb.LogEntryLive.LogEntryComponents do
  use HeadTrendWeb, :live_component

  attr :log_entries, :list, required: true
  attr :class, :string, default: nil
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the container"

  def log_entries_cards(assigns) do
    ~H"""
    <div
      id="log_entries_cards"
      class={[
        @class
      ]}
      {@rest}
    >
      <%= for log_entry <- assigns.log_entries do %>
        <.log_entry_card log_entry={log_entry} />
      <% end %>
    </div>
    """
  end

  attr :log_entry, HeadTrend.Logs.LogEntry, required: true

  def log_entry_card(assigns) do
    ~H"""
    <div
      id={"log_entry_card_#{assigns.log_entry.id}"}
      class="rounded-lg shadow-lg border mt-2
        hover:bg-brand/20 hover:cursor-pointer"
      phx-click={JS.navigate(~p"/log_entries/#{@log_entry}")}
    >
      <.list>
        <:item title="Occurred On">
          <%= @log_entry.occurred_on %>
        </:item>
        
        <:item title="Occurred On">
          <time datetime={@log_entry.occurred_on} id={"#{@log_entry.id}_card_occurred_on"}></time>
        </:item>
        
        <:item title="Headache"><%= if @log_entry.headache, do: "Yes", else: "" %></:item>
        
        <:item title="Fever"><%= if @log_entry.fever, do: "Yes", else: "" %></:item>
        
        <:item title="Pain reliever"><%= @log_entry.pain_reliever %></:item>
        
        <:item title="Debilitating"><%= if @log_entry.debilitating, do: "Yes", else: "" %></:item>
        
        <:item title="Notes"><%= if !is_nil(@log_entry.notes), do: "Yes", else: "" %></:item>
      </.list>
      
      <div class="m-2 p-2 flex gap-4 justify-end">
        <div class="sr-only">
          <.link navigate={~p"/log_entries/#{@log_entry}"}>Show</.link>
        </div>
        
        <.link
          patch={~p"/log_entries/#{@log_entry}/edit"}
          class="hover:text-brand hover:underline hover:underline-offset-4"
        >
          Edit
        </.link>
        
        <.link
          phx-click={
            JS.push("delete", value: %{id: @log_entry.id})
            |> hide("log_entry_card_#{assigns.log_entry.id}")
          }
          data-confirm="Are you sure?"
          class=" hover:text-brand hover:underline hover:underline-offset-4"
        >
          Delete
        </.link>
      </div>
    </div>
    """
  end

  attr :log_entries, :list, required: true
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the container"

  def log_entries_table(assigns) do
    ~H"""
    <div {@rest}>
      <.table
        id="log_entries_table"
        rows={@log_entries}
        row_id={fn log_entry -> "log_entries_table_row_#{log_entry.id}" end}
        row_click={fn log_entry -> JS.navigate(~p"/log_entries/#{log_entry}") end}
      >
        <:col :let={log_entry} label="Occurred on">
          <%= log_entry.occurred_on %>
        </:col>
        
        <:col :let={log_entry} label="Occurred On Local">
          <time datetime={log_entry.occurred_on} id={"#{log_entry.id}_occurred_on"}></time>
        </:col>
        
        <:col :let={log_entry} label="Headache">
          <%= if log_entry.headache, do: "Yes", else: "" %>
        </:col>
        
        <:col :let={log_entry} label="Fever">
          <%= if log_entry.fever, do: "Yes", else: "" %>
        </:col>
        
        <:col :let={log_entry} label="Pain reliever"><%= log_entry.pain_reliever %></:col>
        
        <:col :let={log_entry} label="Debilitating">
          <%= if log_entry.debilitating, do: "Yes", else: "" %>
        </:col>
        
        <:col :let={log_entry} label="Notes">
          <%= if !is_nil(log_entry.notes), do: "Yes", else: "" %>
        </:col>
        
        <:action :let={log_entry}>
          <div class="sr-only">
            <.link navigate={~p"/log_entries/#{log_entry}"}>Show</.link>
          </div>
          
          <.link
            patch={~p"/log_entries/#{log_entry}/edit"}
            class="hover:text-brand hover:underline hover:underline-offset-4"
          >
            Edit
          </.link>
        </:action>
        
        <:action :let={log_entry}>
          <.link
            phx-click={
              JS.push("delete", value: %{id: log_entry.id})
              |> hide("#log_entries_table_row_#{log_entry.id}")
            }
            data-confirm="Are you sure?"
            class=" hover:text-brand hover:underline hover:underline-offset-4"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </div>
    """
  end
end
