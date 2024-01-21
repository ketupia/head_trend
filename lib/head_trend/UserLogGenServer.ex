defmodule HeadTrend.UserLogGenServer do
  @moduledoc """
  UserLogGenServer is a GenServer that holds a list of log entries for the user.
  """
  alias HeadTrend.Logs.LogEntry
  use GenServer

  @idle_timeout 5 * 60 * 1_000

  def get_or_start(user_id) do
    case DynamicSupervisor.start_child(
           HeadTrend.UserLogSupervisor,
           %{
             id: {HeadTrend.UserLogGenServer, user_id},
             start: {HeadTrend.UserLogGenServer, :start_link, [user_id]},
             restart: :transient
           }
         ) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  defp get_registration(user_id) do
    {:via, Registry, {HeadTrend.UserLogRegistry, user_id}}
  end

  def start_link(user_id, opts \\ []) do
    GenServer.start_link(__MODULE__, user_id, [
      {:name, get_registration(user_id)} | opts
    ])
  end

  # Client API
  def add_log_entry(user_id, %LogEntry{} = log_entry) do
    GenServer.cast(get_registration(user_id), {:add_log_entry, log_entry})
  end

  def get_log_entries(user_id) do
    GenServer.call(get_registration(user_id), :get_log_entries)
  end

  # server callbacks

  @impl GenServer
  def init(user_id) do
    log_entries = HeadTrend.Logs.list_log_entries(user_id)
    state = %{user_id: user_id, log_entries: log_entries}
    {:ok, state, @idle_timeout}
  end

  @impl GenServer
  def handle_info(:timeout, _state) do
    Process.exit(self(), :shutdown)
  end

  def handle_info(msg, _state) do
    IO.inspect(msg, label: "#{__MODULE__} Unhandled message")
  end

  @impl GenServer
  def handle_cast({:add_log_entry, %LogEntry{} = log_entry}, state) do
    updated_state = Map.put(state, :log_entries, [log_entry | state.log_entries])
    {:noreply, updated_state, @idle_timeout}
  end

  @impl GenServer
  def handle_call(:get_log_entries, _from, state) do
    {:reply, state.log_entries, state, @idle_timeout}
  end
end
