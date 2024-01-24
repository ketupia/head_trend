defmodule HeadTrendWeb.LogEntryLive.LogEntryComponents do
  use HeadTrendWeb, :html

  alias HeadTrend.Logs.LogEntry
  alias HeadTrendWeb.LogEntryLive.TimezoneAdjustments

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
          <time datetime={@log_entry.occurred_on}>
            <%= TimezoneAdjustments.format_for_display(@log_entry.occurred_on) %>
          </time>
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
          patch={~p"/log_entries/#{@log_entry}/show/edit"}
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
          <time datetime={log_entry.occurred_on}>
            <%= TimezoneAdjustments.format_for_display(log_entry.occurred_on) %>
          </time>
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
            patch={~p"/log_entries/#{log_entry}/show/edit"}
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

  attr :id, :string, default: "log_entries_journal"
  attr :log_entries, :list, required: true
  attr :class, :string, default: nil
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the container"

  def log_entries_journal(assigns) do
    min_max_dates =
      assigns.log_entries
      |> Enum.map(fn le -> DateTime.to_date(le.occurred_on) end)
      |> Enum.min_max(fn -> {Date.utc_today(), Date.utc_today()} end)

    date_range =
      Date.range(elem(min_max_dates, 0), elem(min_max_dates, 1))

    # IO.inspect(date_range, label: "date_range")
    # for d <- date_range do
    #   IO.inspect(d)
    # end

    log_entries_by_date =
      Enum.map(assigns.log_entries, fn le ->
        {DateTime.to_date(le.occurred_on), DateTime.to_time(le.occurred_on), le}
      end)
      |> Enum.group_by(&elem(&1, 0))

    # IO.inspect(log_entries_by_date, label: "log_entries_by_date")

    assigns =
      assigns
      |> assign(:log_entries_by_date, log_entries_by_date)
      |> assign(:date_range, date_range)

    ~H"""
    <div id={@id} class={["border inline-block", @class]} {@rest}>
      <h2 class="bold underline underline-offset-2">Journal</h2>
      
      <div :for={date <- Enum.reverse(assigns.date_range)} id={"#{@id}_#{date}"}>
        <h3 class="bg-slate-300"><time><%= TimezoneAdjustments.format_for_display(date) %></time></h3>
        
        <div
          :for={
            {_date, time, %LogEntry{} = log_entry} <-
              Map.get(assigns.log_entries_by_date, date, []) |> Enum.sort_by(&elem(&1, 1))
          }
          id={"#{@id}_log_entry_#{log_entry.id}"}
          class="grid gap-1 grid-cols-2 hover:bg-brand/20"
          phx-click={JS.navigate(~p"/log_entries/#{log_entry}")}
        >
          <div class="justify-self-end">
            <time><%= TimezoneAdjustments.format_for_display(time) %></time>
          </div>
          
          <div class="grid gap-1 grid-cols-5 content-center">
            <span>
              <img
                :if={log_entry.headache}
                src="/images/headache-illustration-2-svgrepo-com.svg"
                alt=""
                class="h-4 w-4"
                title="Headache"
              />
            </span>
            
            <span>
              <img
                :if={log_entry.fever}
                src="/images/fever-svgrepo-com.svg"
                alt=""
                class="h-4 w-4"
                title="Fever"
              />
            </span>
            
            <span>
              <img
                :if={log_entry.pain_reliever == "acetaminophen"}
                src="/images/medicine-10-svgrepo-com.svg"
                alt=""
                class="h-4 w-4"
                title="Acetaminophen"
              />
              <img
                :if={log_entry.pain_reliever == "ibuprofen"}
                src="/images/medicine-illustration-8-svgrepo-com.svg"
                alt=""
                class="h-4 w-4"
                title="Ibuprofen"
              />
            </span>
            
            <span>
              <img
                :if={log_entry.debilitating}
                src="/images/bed-svgrepo-com.svg"
                alt=""
                class="h-4 w-4"
                title="Debilitating"
              />
            </span>
            
            <span>
              <img
                :if={log_entry.notes}
                src="/images/notes-svgrepo-com.svg"
                alt=""
                class="h-4 w-4"
                title={log_entry.notes}
              />
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
