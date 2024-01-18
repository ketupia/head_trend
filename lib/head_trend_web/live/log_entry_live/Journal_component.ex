defmodule HeadTrendWeb.LogEntryLive.JournalComponent do
  use HeadTrendWeb, :live_component

  alias HeadTrendWeb.LogEntryLive.TimezoneAdjustments
  alias HeadTrend.Logs.LogEntry

  def mount(socket) do
    {:ok, socket |> assign_new(:show_dates_without_log_entries, fn -> true end)}
  end

  def update(assigns, socket) do
    log_entries_by_date =
      assigns.log_entries
      |> Enum.sort_by(& &1.occurred_on)
      |> group_log_entries_by_date()
      |> add_dates_without_log_entries()
      |> convert_to_sorted_list()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:log_entries_by_date, log_entries_by_date)}
  end

  defp convert_to_sorted_list(time_log_entry_tuples_by_date) do
    time_log_entry_tuples_by_date
    |> Enum.to_list()
    |> Enum.sort_by(&elem(&1, 0), :desc)
  end

  @spec group_log_entries_by_date([LogEntry.t()]) :: %{Date.t() => [{Time.t(), LogEntry.t()}]}
  # Groups the given list of log entries by date.
  # Returns a map where the keys are the dates and the values are lists of tuples with the time and log entry for that date.
  defp group_log_entries_by_date(log_entries) when is_list(log_entries) do
    log_entries
    |> Enum.group_by(&DateTime.to_date(&1.occurred_on), fn le ->
      {DateTime.to_time(le.occurred_on), le}
    end)
  end

  defp get_date_range([]), do: Date.range(Date.utc_today(), Date.utc_today())
  @spec get_date_range([Date.t()]) :: Date.Range.t()
  # Returns a `Date.Range` spanning the minimum and maximum dates provided.
  defp get_date_range(dates) do
    dates
    |> Enum.min_max()
    |> (fn {min, max} -> Date.range(min, max) end).()
  end

  @spec add_dates_without_log_entries(%{Date.t() => [{Time.t(), LogEntry.t()}]}) :: %{
          Date.t() => [{Time.t(), LogEntry.t()}]
        }
  # Adds any dates without log entries to the map of log entries by date.
  # This ensures every date in the date range has an entry, even if empty.
  defp add_dates_without_log_entries(time_log_entry_tuples_by_date) do
    date_range = get_date_range(Map.keys(time_log_entry_tuples_by_date))

    date_range
    |> Enum.reduce(time_log_entry_tuples_by_date, fn d, acc ->
      Map.put_new(acc, d, [])
    end)
  end

  def render(assigns) do
    ~H"""
    <div>
      <div id={@id} class="border inline-block p-2">
        <h2 class="bold underline underline-offset-2">Journal</h2>
        
        <div>
          <.input
            id="show_dates_without_log_entries"
            name="show_dates_without_log_entries"
            type="checkbox"
            label="Show dates without log entries"
            checked={@show_dates_without_log_entries}
            phx-click="toggle_show_dates_without_log_entries"
            phx-target={@myself}
          />
        </div>
        
        <div
          :for={{date, time_log_entry_tuples} <- assigns.log_entries_by_date}
          :if={@show_dates_without_log_entries || length(time_log_entry_tuples) > 0}
          id={"#{@id}_#{date}"}
        >
          <h3 class="bg-slate-300">
            <time><%= TimezoneAdjustments.format_for_display(date) %></time>
          </h3>
          
          <div class="divide-y divide-brand/20">
            <.render_time_log_entry_row
              :for={{time, %LogEntry{} = log_entry} <- time_log_entry_tuples}
              id={"#{@id}_log_entry_#{log_entry.id}"}
              time={time}
              log_entry={log_entry}
            />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_time_log_entry_row(assigns) do
    ~H"""
    <div
      id={@id}
      class="grid gap-2 grid-cols-5 hover:bg-brand/20 "
      phx-click={JS.navigate(~p"/log_entries/#{@log_entry}")}
    >
      <div class="justify-self-end col-span-2">
        <time><%= TimezoneAdjustments.format_for_display(@time) %></time>
      </div>
       <.render_log_entry log_entry={@log_entry} />
    </div>
    """
  end

  defp render_log_entry(assigns) do
    ~H"""
    <div class="col-span-3 grid gap-1 grid-cols-5 content-center">
      <.render_log_entry_indicator
        display?={@log_entry.headache}
        image_src="/images/headache-illustration-2-svgrepo-com.svg"
        title="Headache"
      />
      <.render_log_entry_indicator
        display?={@log_entry.fever}
        image_src="/images/fever-svgrepo-com.svg"
        title="Fever"
      />
      <span>
        <.render_log_entry_indicator
          display?={@log_entry.pain_reliever == "acetaminophen"}
          image_src="/images/medicine-10-svgrepo-com.svg"
          title="Acetaminophen"
        />
        <.render_log_entry_indicator
          display?={@log_entry.pain_reliever == "ibuprofen"}
          image_src="/images/medicine-illustration-8-svgrepo-com.svg"
          title="Ibuprofen"
        />
      </span>
      
      <.render_log_entry_indicator
        display?={@log_entry.debilitating}
        image_src="/images/bed-svgrepo-com.svg"
        title="Debilitating"
      />
      <.render_log_entry_indicator
        display?={@log_entry.notes}
        image_src="/images/notes-svgrepo-com.svg"
        title="Notes"
      />
    </div>
    """
  end

  defp render_log_entry_indicator(assigns) do
    ~H"""
    <span>
      <img :if={@display?} src={@image_src} alt="" class="h-4 w-4" title={@title} />
    </span>
    """
  end

  def handle_event("toggle_show_dates_without_log_entries", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_dates_without_log_entries, !socket.assigns.show_dates_without_log_entries)}
  end
end
