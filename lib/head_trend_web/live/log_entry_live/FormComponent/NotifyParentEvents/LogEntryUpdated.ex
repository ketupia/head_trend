defmodule HeadTrendWeb.LogEntryLive.FormComponent.NotifyParentEvents.LogEntryUpdated do
  @moduledoc """
  The message struct when a Log Entry is updated
  """
  use TypedStruct

  typedstruct enforce: true do
    field :log_entry, HeadTrend.Logs.LogEntry.t()
  end

  def new(log_entry) when not is_nil(log_entry) do
    %__MODULE__{log_entry: log_entry}
  end

  def new(_log_entry) do
    raise "log_entry can't be nil"
  end
end
