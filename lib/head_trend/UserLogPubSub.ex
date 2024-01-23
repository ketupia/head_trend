defmodule HeadTrend.UserLogPubSub do
  alias HeadTrend.Logs.LogEntry
  use TypedStruct

  typedstruct module: LogEntryCreated, enforce: true do
    field :log_entry, LogEntry.t()
  end

  typedstruct module: LogEntryUpdated, enforce: true do
    field :log_entry, LogEntry.t()
  end

  typedstruct module: LogEntryDeleted, enforce: true do
    field :log_entry, LogEntry.t()
  end

  defp get_pub_sub_topic(user_id), do: "UserLogEntries_#{user_id}"

  def subscribe(user_id) do
    Phoenix.PubSub.unsubscribe(HeadTrend.PubSub, get_pub_sub_topic(user_id))
    Phoenix.PubSub.subscribe(HeadTrend.PubSub, get_pub_sub_topic(user_id))
  end

  def publish_log_entry_created(%LogEntry{} = log_entry),
    do:
      Phoenix.PubSub.broadcast(
        HeadTrend.PubSub,
        get_pub_sub_topic(log_entry.user_id),
        %LogEntryCreated{
          log_entry: log_entry
        }
      )

  def publish_log_entry_updated(%LogEntry{} = log_entry),
    do:
      Phoenix.PubSub.broadcast(
        HeadTrend.PubSub,
        get_pub_sub_topic(log_entry.user_id),
        %LogEntryUpdated{
          log_entry: log_entry
        }
      )

  def publish_log_entry_deleted(%LogEntry{} = log_entry),
    do:
      Phoenix.PubSub.broadcast(
        HeadTrend.PubSub,
        get_pub_sub_topic(log_entry.user_id),
        %LogEntryDeleted{
          log_entry: log_entry
        }
      )
end
