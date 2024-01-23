defmodule HeadTrend.UserLogGenServer do
  @moduledoc """
  UserLogGenServer is a GenServer that holds a list of log entries for the user.
  """
  alias HeadTrend.Logs
  alias HeadTrend.Logs.LogEntry
  alias HeadTrend.UserLogPubSub
  use GenServer

  @idle_timeout 5 * 60 * 1_000

  def get_or_start(user_id) do
    case DynamicSupervisor.start_child(
           HeadTrend.UserLogSupervisor,
           %{
             id: get_registration(user_id),
             start: {HeadTrend.UserLogGenServer, :start_link, [user_id]},
             restart: :transient
           }
         ) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
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

  @spec get_log_entries(user_id :: String.t()) ::
          {:ok, [LogEntry.t()]} | {:error, :not_found}
  def get_log_entries(user_id) do
    get_or_start(user_id)
    |> GenServer.call(:get_log_entries)
  end

  @spec get_log_entry(user_id :: String.t(), log_entry_id :: integer()) ::
          {:ok, LogEntry.t()} | {:error, :not_found}
  def get_log_entry(user_id, log_entry_id) when is_binary(log_entry_id),
    do: get_log_entry(user_id, String.to_integer(log_entry_id))

  @spec get_log_entry(user_id :: Integer.t(), log_entry_id :: integer()) ::
          {:ok, LogEntry.t()} | {:error, :not_found}
  def get_log_entry(user_id, log_entry_id) do
    get_or_start(user_id)
    |> GenServer.call({:get_log_entry, log_entry_id})
  end

  @spec create_log_entry(attrs :: map()) :: {:ok, LogEntry.t()} | {:error, any()}
  def create_log_entry(%{} = attrs) do
    get_or_start(attrs["user_id"])
    |> GenServer.call({:create_log_entry, attrs})
  end

  @spec update_log_entry(log_entry :: LogEntry.t(), attrs :: map()) ::
          {:ok, LogEntry.t()} | {:error, any()}
  def update_log_entry(%LogEntry{} = log_entry, %{} = attrs) do
    get_or_start(log_entry.user_id)
    |> GenServer.call({:update_log_entry, log_entry, attrs})
  end

  @spec delete_log_entry(log_entry :: LogEntry.t()) ::
          {:ok, LogEntry.t()} | {:error, Ecto.Changeset.t()}
  def delete_log_entry(%LogEntry{} = log_entry) do
    get_or_start(log_entry.user_id)
    |> GenServer.call({:delete_log_entry, log_entry})
  end

  # server callbacks

  use TypedStruct

  typedstruct enforce: true, module: MyState do
    field :user_id, String.t()
    field :log_entries, [LogEntry.t()]
  end

  @impl GenServer
  def init(user_id) do
    log_entries = Logs.list_log_entries(user_id)
    state = %MyState{user_id: user_id, log_entries: log_entries}
    {:ok, state, @idle_timeout}
  end

  @impl GenServer
  def handle_info(:timeout, %MyState{user_id: user_id}) do
    IO.inspect(user_id, label: "#{__MODULE__} timeout for user")
    Process.exit(self(), :shutdown)
  end

  def handle_info(msg, _state) do
    IO.inspect(msg, label: "#{__MODULE__} Unhandled message")
  end

  @impl GenServer
  def handle_call(:get_log_entries, _from, %MyState{} = state) do
    {:reply, state.log_entries, state, @idle_timeout}
  end

  @impl GenServer
  def handle_call({:get_log_entry, log_entry_id}, _from, %MyState{} = state) do
    log_entry = Enum.find(state.log_entries, fn entry -> entry.id == log_entry_id end)
    {:reply, log_entry, state, @idle_timeout}
  end

  @impl GenServer
  def handle_call({:create_log_entry, %{} = attrs}, _from, %MyState{} = state) do
    case Logs.create_log_entry(attrs) do
      {:ok, %LogEntry{} = new_log_entry} ->
        updated_state =
          Map.put(
            state,
            :log_entries,
            [new_log_entry | state.log_entries]
            |> Enum.sort_by(& &1.occurred_on, &>=/2)
          )

        UserLogPubSub.publish_log_entry_created(new_log_entry)

        {:reply, {:ok, new_log_entry}, updated_state, @idle_timeout}

      {:error, reason} ->
        {:reply, {:error, reason}, state, @idle_timeout}
    end
  end

  @impl GenServer
  def handle_call(
        {:update_log_entry, %LogEntry{} = log_entry, %{} = attrs},
        _from,
        %MyState{} = state
      ) do
    case Logs.update_log_entry(log_entry, attrs) do
      {:ok, %LogEntry{} = updated_log_entry} ->
        updated_state =
          Map.put(
            state,
            :log_entries,
            [
              updated_log_entry
              | Enum.reject(state.log_entries, fn entry -> entry.id == log_entry.id end)
            ]
            |> Enum.sort_by(& &1.occurred_on, &>=/2)
          )

        UserLogPubSub.publish_log_entry_updated(updated_log_entry)

        {:reply, {:ok, updated_log_entry}, updated_state, @idle_timeout}

      {:error, reason} ->
        {:reply, {:error, reason}, state, @idle_timeout}
    end
  end

  @impl GenServer
  def handle_call({:delete_log_entry, %LogEntry{} = log_entry}, _from, %MyState{} = state) do
    case Logs.delete_log_entry(log_entry) do
      {:ok, _} ->
        updated_state =
          Map.put(
            state,
            :log_entries,
            Enum.reject(state.log_entries, fn entry -> entry.id == log_entry.id end)
          )

        UserLogPubSub.publish_log_entry_deleted(log_entry)
        {:reply, {:ok, log_entry}, updated_state, @idle_timeout}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:reply, {:error, changeset}, state, @idle_timeout}
    end
  end
end
