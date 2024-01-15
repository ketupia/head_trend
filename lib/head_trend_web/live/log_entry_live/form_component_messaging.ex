defmodule HeadTrendWeb.LogEntryLive.FormComponentMessaging do
  @moduledoc """
  The idea behind the three sub-modules here is to ensure messages published are consumed
  and that there aren't any mismatches between senders and receivers.

  The MsgPayloadFactory and HandleInfoAdapter handle the soft bits that can't be checked
  with the compiler.

  The HandleInfoAdapter and MsgReceiver behaviour ensure the listener has a compiler
  checkable interface.

  An area that I have yet to know is if notify_parent differs from other messaging facilities
  such as pub/sub.  If they do, will the same payload work for all of them?
  I'm sure I'll need handle_event at some point.  Perhaps that will suffice
  """

  defmodule MsgPayloadFactory do
    @moduledoc """
    These methods construct the payload for the notify_parent calls.
    """
    alias HeadTrend.Logs.LogEntry

    def log_entry_created(%LogEntry{} = log_entry) do
      {:created, log_entry}
    end

    def log_entry_updated(%LogEntry{} = log_entry) do
      {:updated, log_entry}
    end
  end

  defmodule HandleInfoAdapter do
    @moduledoc """
    Handle Info Adapter maps the soft bits in the payload to MsgReceiver methods.

    I have the return starting with a boolean.  My thinking is that in a more complex environment,
    a module might be listening to multiple senders and thus need to call multiple adapters until
    one handles the msg.

    The brute force alternative, which might be just as good, is to simple call them all.  In theory,
    only one should match!
    """
    alias HeadTrend.Logs.LogEntry

    @spec handle_info(term(), Phoenix.LiveView.Socket.t(), module()) ::
            {boolean(), Phoenix.LiveView.Socket.t()}
    def handle_info(msg, socket, msg_receiver) do
      case msg do
        {HeadTrendWeb.LogEntryLive.FormComponent, {:created, %LogEntry{} = log_entry}} ->
          {true, msg_receiver.log_entry_created(log_entry, socket)}

        {HeadTrendWeb.LogEntryLive.FormComponent, {:updated, %LogEntry{} = log_entry}} ->
          {true, msg_receiver.log_entry_updated(log_entry, socket)}

        _ ->
          {false, socket}
      end
    end
  end

  defmodule MsgReceiver do
    @callback log_entry_created(HeadTrend.Logs.LogEntry.t(), Phoenix.LiveView.Socket.t()) ::
                Phoenix.LiveView.Socket.t()
    @callback log_entry_updated(HeadTrend.Logs.LogEntry.t(), Phoenix.LiveView.Socket.t()) ::
                Phoenix.LiveView.Socket.t()
  end
end
